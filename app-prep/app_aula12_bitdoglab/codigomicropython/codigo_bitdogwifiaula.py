# ===== BitDog Lab - WiFi + RGB + Botões + Buzzer + Matriz WS2812B =====
import network, time, machine, socket
from machine import ADC, Pin, PWM, I2C
import neopixel
import json
from time import sleep
import BME280
import ure as re  # 're' do MicroPython

# ======= HARDWARE =======
LED_R_PIN, LED_G_PIN, LED_B_PIN = 13, 11, 12  # ajuste conforme sua placa
BOTAO_A_PIN, BOTAO_B_PIN = 5, 6               # pull-up (pressionado = 0)
BUZZER_PIN = 21
NEO_PIN = 7                                   # Matriz 5x5 WS2812B no pino 7
ACTIVE_HIGH = True                            # Troque p/ False se LED for invertido

# I2C (Pico W: I2C(1) com SDA=GP2, SCL=GP3)
i2c = I2C(id=1, scl=Pin(3), sda=Pin(2), freq=100000)

# ======= MATRIZ 5x5 =======
MATRIX_W, MATRIX_H = 5, 5
NUM_LEDS = MATRIX_W * MATRIX_H
SERPENTINE = False   # True se a fiação for zig-zag
H_MIRROR   = True    # True corrige o "S" invertido
V_MIRROR   = False

# ======= OBJETOS =======
r = Pin(LED_R_PIN, Pin.OUT)
g = Pin(LED_G_PIN, Pin.OUT)
b = Pin(LED_B_PIN, Pin.OUT)
botaoA = Pin(BOTAO_A_PIN, Pin.IN, Pin.PULL_UP)
botaoB = Pin(BOTAO_B_PIN, Pin.IN, Pin.PULL_UP)
buzzer = PWM(Pin(BUZZER_PIN)); buzzer.duty_u16(0)
np = neopixel.NeoPixel(Pin(NEO_PIN, Pin.OUT), NUM_LEDS)
sensor_de_temperatura = ADC(4)

# ======= FUNÇÕES BÁSICAS =======
def _num(x, default=float('nan')):
    try:
        if isinstance(x, (int, float)):
            return float(x)
        m = re.search(r'[-+]?\d*\.?\d+', str(x))
        return float(m.group()) if m else default
    except Exception:
        return default

def leitura_bme280():
    """Retorna apenas a temperatura em °C (float). Robusto a falhas do I2C."""
    try:
        bme = BME280.BME280(i2c=i2c, addr=0x76)
        if hasattr(bme, "read_temperature"):
            t = bme.read_temperature() / 100.0
        else:
            t = _num(getattr(bme, "temperature", "nan"))
        if t != t:  # NaN
            t = 0.0
        return float(t)
    except Exception:
        return 0.0

def write_led(pin, on: bool):
    pin.value(1 if (on and ACTIVE_HIGH) or (not on and not ACTIVE_HIGH) else 0)

def all_off_rgb():
    write_led(r, False); write_led(g, False); write_led(b, False)

def beep(freq=1800, ms=150):
    buzzer.freq(freq); buzzer.duty_u16(32768); time.sleep(ms/1000); buzzer.duty_u16(0)

def logical_to_index(x, y):
    if H_MIRROR:
        x = MATRIX_W - 1 - x
    if V_MIRROR:
        y = MATRIX_H - 1 - y
    if SERPENTINE and (y % 2 == 1):
        x = MATRIX_W - 1 - x
    return y * MATRIX_W + x

def clear_matrix():
    for i in range(NUM_LEDS):
        np[i] = (0, 0, 0)
    np.write()

def draw_bitmap5(lines, color=(0,120,0), bg=(0,0,0)):
    assert len(lines) == MATRIX_H and all(len(rw) == MATRIX_W for rw in lines)
    for y, row in enumerate(lines):
        for x, ch in enumerate(row):
            np[logical_to_index(x, y)] = color if ch == '1' else bg
    np.write()

def mirror_h(lines):
    return [''.join(reversed(row)) for row in lines]

# ======== BITMAPS 5x5 =========
BITMAPS = {
    "S":       ["11111","10000","11111","00001","11111"],
    "smile":   ["01110","10101","10001","10001","01110"],
    "giraffe": ["00100","01110","01010","11100","01000"],
    "heart":   ["00100","01110","11111","11111","01010"],
    "pacman":  ["01110","00011","00111","00011","01110"],
    "happy":   ["01110","10001","10101","10001","01110"],
    "duck":    ["01111","01110","11100","01110","00100"],
}

def draw_named(name, *, color=(0,0,100), bg=(0,0,0), extra_mirror_h=False):
    lines = BITMAPS.get(name)
    if not lines:
        return
    if extra_mirror_h:
        lines = mirror_h(lines)
    draw_bitmap5(lines, color=color, bg=bg)

# ======= WIFI =======
def realiza_conexao():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect("", "")
    wait = 10
    while wait > 0:
        s = wlan.status()
        if s < 0 or s >= 3: break
        print("Aguardando conexao..." if wait==10 else ".")
        wait -= 1; time.sleep(1)
    if wlan.status() != 3: raise RuntimeError("a conexao falhou")
    ip = wlan.ifconfig()[0]
    print("conectado, IP:", ip)
    return ip

def abre_socket(ip):
    s = socket.socket()
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((ip,80)); s.listen(1)
    s.settimeout(0.5)   # timeout no servidor (define UMA vez)
    return s

# ======= SENSORES/ESTADOS =======
def le_temperatura_interna():
    val = sensor_de_temperatura.read_u16()
    v = val * (3.3/65535.0)
    return 27 - (v - 0.706)/0.001721

def estado_botoes():
    return {"A": "pressionado" if botaoA.value()==0 else "solto",
            "B": "pressionado" if botaoB.value()==0 else "solto"}

def estado_leds():
    def is_on(pin): return pin.value()==(1 if ACTIVE_HIGH else 0)
    return {"R": "on" if is_on(r) else "off",
            "G": "on" if is_on(g) else "off",
            "B": "on" if is_on(b) else "off"}

def build_status_dict():
    t = leitura_bme280()
    return {
        "temperatura_c": round(t, 2),
        "botoes": estado_botoes(),
        "leds":   estado_leds(),
    }

# ======= HTTP PARSER/POST =======
def parse_http_request(req_bytes):
    text = req_bytes.decode('utf-8')
    lines = text.split("\r\n")
    request_line = lines[0] if lines else ""
    parts = request_line.split()
    method = parts[0] if len(parts) > 0 else "GET"
    path = parts[1] if len(parts) > 1 else "/"
    headers = {}
    i = 1
    while i < len(lines) and lines[i]:
        if ":" in lines[i]:
            k, v = lines[i].split(":", 1)
            headers[k.strip().lower()] = v.strip()
        i += 1
    body = "\r\n".join(lines[i+1:])  # após linha em branco
    return method, path, headers, body

def read_json(body):
    try:
        return json.loads(body or "{}")
    except:
        return {}

def resp_json(obj, status=200):
    body = json.dumps(obj)
    headers = (
        f"HTTP/1.1 {status} OK\r\n"
        "Content-Type: application/json; charset=utf-8\r\n"
        "Connection: close\r\n"
        f"Content-Length: {len(body)}\r\n\r\n"
    )
    return headers, body

def trata_post(path, payload):
    def as_bool(v):
        return bool(int(v)) if isinstance(v, (str, int)) else bool(v)

    if path == "/status_json":
        return {"ok": True, "status": build_status_dict()}

    if path in ("/r_on", "/r"):
        v = payload.get("led_vermelho", payload.get("valor", payload.get("on", 1)))
        write_led(r, as_bool(v))
        return {"ok": True, "R": "on" if as_bool(v) else "off"}

    if path in ("/g_on", "/g"):
        v = payload.get("led_verde", payload.get("valor", payload.get("on", 1)))
        write_led(g, as_bool(v))
        return {"ok": True, "G": "on" if as_bool(v) else "off"}

    if path in ("/b_on", "/b"):
        v = payload.get("led_azul", payload.get("valor", payload.get("on", 1)))
        write_led(b, as_bool(v))
        return {"ok": True, "B": "on" if as_bool(v) else "off"}

    if path == "/rgb":
        rv = as_bool(payload.get("r", 0))
        gv = as_bool(payload.get("g", 0))
        bv = as_bool(payload.get("b", 0))
        write_led(r, rv); write_led(g, gv); write_led(b, bv)
        return {"ok": True, "R": rv, "G": gv, "B": bv}

    if path == "/beep":
        freq = int(payload.get("freq", 1800))
        ms   = int(payload.get("ms", 150))
        beep(freq=freq, ms=ms)
        return {"ok": True, "freq": freq, "ms": ms}

    if path == "/matrix":
        pat = payload.get("pattern")
        if pat:
            draw_named(pat)
            return {"ok": True, "pattern": pat}
        bm = payload.get("bitmap")
        if bm:
            draw_bitmap5(bm)
            return {"ok": True, "bitmap": True}
        return {"ok": False, "error": "payload invalido"}

    return {"ok": False, "error": "rota POST desconhecida"}

# ======= HTML =======
def pagina_web(temp_c):
    leds = estado_leds(); btns = estado_botoes()
    body = f"""<!DOCTYPE html><html><head><meta charset="utf-8"/><title>BitDog Lab</title>
<style>
body{{font-family:Arial;max-width:420px;margin:1rem auto}}
.btn{{display:inline-block;padding:.6rem .8rem;border:1px solid #999;border-radius:.5rem;text-decoration:none;margin:.2rem 0}}
.badge{{padding:.2rem .5rem;border-radius:.4rem;background:#eee;margin-left:.25rem}}
.card{{border:1px solid #ddd;border-radius:.6rem;padding:.8rem;margin:.6rem 0}}
.row{{display:flex;gap:.5rem;flex-wrap:wrap}}
</style></head><body>
<h1>BitDog Lab • Controle</h1>

<div class="card"><b>Temperatura:</b> {temp_c:.2f} °C</div>

<div class="card">
  <b>Botões</b>
  <div>A <span class="badge">{btns['A']}</span> &nbsp; B <span class="badge">{btns['B']}</span></div>
</div>

<div class="card">
  <b>LED RGB</b>
  <span class="badge">R: {leds['R']}</span>
  <span class="badge">G: {leds['G']}</span>
  <span class="badge">B: {leds['B']}</span>
  <div class="row" style="margin-top:.5rem">
    <a class="btn" href="/rgb_on">RGB ON</a>
    <a class="btn" href="/rgb_off">RGB OFF</a>
    <a class="btn" href="/r_on">R ON</a>
    <a class="btn" href="/r_off">R OFF</a>
    <a class="btn" href="/g_on">G ON</a>
    <a class="btn" href="/g_off">G OFF</a>
    <a class="btn" href="/b_on">B ON</a>
    <a class="btn" href="/b_off">B OFF</a>
  </div>
</div>

<div class="card">
  <b>Buzzer</b>
  <div class="row"><a class="btn" href="/beep">Beep</a></div>
</div>

<div class="card">
  <b>Matriz 5×5</b>
  <div class="row">
    <a class="btn" href="/draw_s">Desenhar S</a>
    <a class="btn" href="/smile">Smile 😊</a>
    <a class="btn" href="/giraffe">Giraffe</a>
    <a class="btn" href="/heart">Heart</a>
    <a class="btn" href="/pacman">Pacman</a>
    <a class="btn" href="/happy">Happy</a>
    <a class="btn" href="/duck">Duck</a>
    <a class="btn" href="/clear">Limpar</a>
  </div>
  <small>Dica: Botão A → “S”, Botão B → “Smile”.</small>
</div>

<div class="card"><small>Atualize para ver estados recentes.</small></div>
</body></html>"""
    return body

# ======= ROTAS (GET) =======
def trata_rota(path):
    if   path == "/rgb_on":  write_led(r,True); write_led(g,True); write_led(b,True)
    elif path == "/rgb_off": all_off_rgb()
    elif path == "/r_on":    write_led(r,True)
    elif path == "/r_off":   write_led(r,False)
    elif path == "/g_on":    write_led(g,True)
    elif path == "/g_off":   write_led(g,False)
    elif path == "/b_on":    write_led(b,True)
    elif path == "/b_off":   write_led(b,False)
    elif path == "/beep":    beep()
    elif path == "/draw_s":  draw_named("S")
    elif path == "/smile":   draw_named("smile")
    elif path == "/giraffe": draw_named("giraffe")
    elif path == "/heart":   draw_named("heart")
    elif path == "/pacman":  draw_named("pacman")
    elif path == "/happy":   draw_named("happy")
    elif path == "/duck":    draw_named("duck")
    elif path == "/clear":   clear_matrix()
    # Outros paths: apenas render HTML

# ======= SERVIDOR (com polling dos botões) =======
def roda_servidor(sock):
    all_off_rgb(); clear_matrix()
    lastA, lastB = 1, 1

    while True:
        # 1) Leia sensores UMA vez por iteração
        temp_c = leitura_bme280()

        # 2) Polling dos botões físicos
        va, vb = botaoA.value(), botaoB.value()
        if lastA == 1 and va == 0:
            draw_named("S");     beep(1200, 90)
        if lastB == 1 and vb == 0:
            draw_named("smile"); beep(1500, 90)
        lastA, lastB = va, vb

        # 3) Aceite conexões com timeout no servidor
        try:
            cliente, addr = sock.accept()
        except OSError:
            continue

        try:
            # Timeout só no cliente e mais folgado
            cliente.settimeout(3.0)

            # --- recepção do cabeçalho HTTP ---
            req = b""
            while b"\r\n\r\n" not in req:
                chunk = cliente.recv(512)
                if not chunk:
                    break
                req += chunk
                if len(req) > 8192:
                    break

            if not req:
                cliente.close()
                continue

            method, path, headers, body = parse_http_request(req)

            # --- se for POST, leia Content-Length ---
            cl = int(headers.get("content-length", "0"))
            while len(body.encode("utf-8")) < cl:
                more = cliente.recv(min(1024, cl))
                if not more:
                    break
                body += more.decode("utf-8")

            if method == "POST":
                payload = read_json(body)
                result  = trata_post(path, payload)
                h, j = resp_json(result, 200 if result.get("ok") else 400)
                cliente.send(h); cliente.sendall(j)
            else:
                if path == "/status_json":
                    status = {
                        "temperatura_c": round(temp_c, 2),
                        "botoes": estado_botoes(),
                        "leds":   estado_leds(),
                    }
                    h, j = resp_json({"ok": True, "status": status}, 200)
                    cliente.send(h); cliente.sendall(j)
                else:
                    trata_rota(path)
                    body_html = pagina_web(temp_c)
                    headers_html = (
                        "HTTP/1.1 200 OK\r\n"
                        "Content-Type: text/html; charset=utf-8\r\n"
                        "Connection: close\r\n"
                        f"Content-Length: {len(body_html)}\r\n\r\n"
                    )
                    cliente.send(headers_html); cliente.sendall(body_html)

        except Exception as e:
            print("Erro req:", e)
        finally:
            try:
                cliente.close()
            except:
                pass

# ======= MAIN =======
try:
    ip = realiza_conexao()
    s = abre_socket(ip)
    print("Servidor em http://{}/".format(ip))
    roda_servidor(s)
except Exception as e:
    print("Reiniciando...", e)
    # machine.reset()
