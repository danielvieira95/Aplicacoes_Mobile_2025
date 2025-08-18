import 'package:flutter/material.dart';
import '../data/dog_dao.dart';
import '../models/dog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dao = DogDao();

  final _nomeCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();

  Dog? _editing; // null = inserindo; not null = editando

  Future<List<Dog>>? _futureDogs;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      final q = _searchCtrl.text.trim();
      _futureDogs = q.isEmpty ? _dao.getAll() : _dao.searchByName(q);
    });
  }

  void _clearForm() {
    _nomeCtrl.clear();
    _idadeCtrl.clear();
    _editing = null;
  }

  void _edit(Dog dog) {
    setState(() {
      _editing = dog;
      _nomeCtrl.text = dog.nome;
      _idadeCtrl.text = dog.idade.toString();
    });
  }

  Future<void> _save() async {
    final nome = _nomeCtrl.text.trim();
    final idadeStr = _idadeCtrl.text.trim();

    if (nome.isEmpty || idadeStr.isEmpty) {
      _snack('Preencha nome e idade.');
      return;
    }

    final idade = int.tryParse(idadeStr);
    if (idade == null) {
      _snack('Idade precisa ser um número inteiro.');
      return;
    }

    if (_editing == null) {
      await _dao.insert(Dog(nome: nome, idade: idade));
      _snack('Pet cadastrado!');
    } else {
      await _dao.update(_editing!.copyWith(nome: nome, idade: idade));
      _snack('Pet atualizado!');
    }

    _clearForm();
    _reload();
  }

  Future<void> _delete(int id) async {
    await _dao.delete(id);
    _snack('Pet removido.');
    _reload();
  }

  void _cancelEdit() {
    _clearForm();
    _snack('Edição cancelada.');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _editing != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pets (sqflite)'),
      ),
      body: Column(
        children: [
          // ===== Busca =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                hintText: 'Ex.: Rocky',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: 'Limpar busca',
                  onPressed: () {
                    _searchCtrl.clear();
                    _reload();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onChanged: (_) => _reload(),
            ),
          ),
          // ===== Formulário =====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nomeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nome do pet',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _idadeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Idade (anos)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: Icon(isEditing ? Icons.save : Icons.add),
                        label:
                            Text(isEditing ? 'Salvar alterações' : 'Adicionar'),
                      ),
                    ),
                    if (isEditing) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _cancelEdit,
                          icon: const Icon(Icons.close),
                          label: const Text('Cancelar'),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // ===== Lista =====
          Expanded(
            child: FutureBuilder<List<Dog>>(
              future: _futureDogs,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final dogs = snapshot.data ?? [];
                if (dogs.isEmpty) {
                  return const Center(child: Text('Nenhum pet encontrado.'));
                }

                return ListView.builder(
                  itemCount: dogs.length,
                  itemBuilder: (context, index) {
                    final dog = dogs[index];
                    return ListTile(
                      title: Text(dog.nome),
                      subtitle: Text('Idade: ${dog.idade}'),
                      leading:
                          CircleAvatar(child: Text((dog.id ?? 0).toString())),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit),
                            onPressed: () => _edit(dog),
                          ),
                          IconButton(
                            tooltip: 'Excluir',
                            icon: const Icon(Icons.delete),
                            onPressed: () => _delete(dog.id!),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
