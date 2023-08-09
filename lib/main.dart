import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const AvgCalcApp());
}

class AvgCalcApp extends StatelessWidget {
  const AvgCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Average Grade Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(title: 'Average Grade Calculator'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class Entry {
  Entry({required this.name, required this.value, required this.weight});

  String name;
  double value;
  double weight;
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  final List<Entry> _entries = [];
  double _average = double.nan;

  void _updateAverage() {
    double sum = 0, sumWeights = 0;
    for (Entry entry in _entries) {
      sum += entry.value*entry.weight;
      sumWeights += entry.weight;
    }
    _average = sum/sumWeights;
  }

  String prettyDouble(double x) {
    return x % 1.0 == 0.0 ? x.toStringAsFixed(0) : x.toString();
  }

  _getEditBuilder(String titleStr, Widget cancelButton, Widget confirmButton) {
    Widget clearButton = TextButton(
      child: const Text("Clear"),
      onPressed: () {
        nameController.text = "";
        valueController.text = "";
        weightController.text = "";
      },
    );

    return AlertDialog(
      title: Text(titleStr),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Course',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: valueController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))],
              decoration: const InputDecoration(
                labelText: 'Grade',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || double.tryParse(value) == null) {
                  return 'Please enter a valid grade';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'(^\d*\.?\d*)'))],
              decoration: const InputDecoration(
                labelText: 'Weight',
              ),
              validator: (value) {
                if (value == null || value.isEmpty || double.tryParse(value) == null) {
                  return 'Please enter a valid weight';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        clearButton,
        cancelButton,
        confirmButton,
      ],
    );
  }

  void _addEntry() {
    Widget confirmAddEntryButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          Navigator.of(context).pop();
          Entry newEntry = Entry(name: nameController.text, value: double.parse(valueController.text),
              weight: double.parse(weightController.text));
          setState(() {
            _entries.add(newEntry);
            _updateAverage();
          });
        }
      },
    );
    Widget cancelAddEntryButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {Navigator.of(context).pop();},
    );

    showDialog(
      context: context,
      builder: (context) {
        return _getEditBuilder("Add new entry", cancelAddEntryButton, confirmAddEntryButton);
      },
    );
  }

  void _editEntry(int index) {
    Widget confirmEditEntryButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          Navigator.of(context).pop();
          setState(() {
            _entries[index].name = nameController.text;
            _entries[index].value = double.parse(valueController.text);
            _entries[index].weight = double.parse(weightController.text);
            _updateAverage();
          });
        }
      },
    );
    Widget cancelEditEntryButton = TextButton(
      child: const Text("Cancel"),
      onPressed: () {Navigator.of(context).pop();},
    );

    nameController.text = _entries[index].name;
    valueController.text = prettyDouble(_entries[index].value);
    weightController.text = prettyDouble(_entries[index].weight);

    showDialog(
      context: context,
      builder: (context) {
        return _getEditBuilder("Edit entry", cancelEditEntryButton, confirmEditEntryButton);
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    valueController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ReorderableListView.builder(itemBuilder: (BuildContext context, int index) {
        final entry = _entries[index];
        return buildEntry(index, entry);
      }, itemCount: _entries.length, onReorder: (oldIndex, newIndex) => setState(() {
        final index = newIndex > oldIndex ? newIndex - 1 : newIndex;
        final entry = _entries.removeAt(oldIndex);
        _entries.insert(index, entry);
      }), padding: const EdgeInsets.only(bottom: 80.0),),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        tooltip: 'Add entry',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Average", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(_average.isNaN ? "N/A" : _average.toStringAsFixed(3), style: const TextStyle(fontSize: 24)),
              ]
          ),
        ),
      ),
    );
  }

  Widget buildEntry(int index, Entry entry) => ListTile(
    key: ValueKey(entry),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    title: Text(entry.name),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.class_),
            const SizedBox(width: 5),
            Text(prettyDouble(entry.value)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.balance),
            const SizedBox(width: 5),
            Text(prettyDouble(entry.weight)),
          ],
        ),
      ],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => edit(index),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _promptRemove(index),
        ),
      ],
    ),
  );

  void _promptRemove(int index) {
    Widget confirmRemoveButton = TextButton(
      child: const Text("Yes"),
      onPressed: () {
        Navigator.of(context).pop();
        remove(index);
      },
    );
    Widget cancelRemoveButton = TextButton(
      child: const Text("No"),
      onPressed: () {Navigator.of(context).pop();},
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: Text("Delete entry ${_entries[index].name}?"),
          actions: [
            cancelRemoveButton,
            confirmRemoveButton,
          ],
        );
      },
    );
  }

  void remove(int index) => setState(() {
    _entries.removeAt(index);
    _updateAverage();
  });

  void edit(int index) {
    _editEntry(index);
  }
}
