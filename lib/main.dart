import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'generate random word',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          onPrimary: Colors.white,
          background: const Color(0xFFF5F5F5),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
      ),
      home: RandomWords(),
    );
  }
}

// Custom class untuk menangani kata dengan bagian kedua opsional
class CustomWordPair {
  final String first;
  final String second;

  CustomWordPair(this.first, this.second);

  String get asPascalCase {
    if (second.isEmpty) {
      return _capitalize(first);
    }
    return _capitalize(first) + _capitalize(second);
  }

  String _capitalize(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  @override
  String toString() => asPascalCase;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomWordPair &&
          runtimeType == other.runtimeType &&
          first == other.first &&
          second == other.second;

  @override
  int get hashCode => first.hashCode ^ second.hashCode;

  // Convert to WordPair untuk kompatibilitas dengan fungsi yang membutuhkan WordPair
  WordPair toWordPair() {
    if (second.isEmpty) {
      return WordPair(first, first); // Gunakan kata pertama sebagai pengganti
    }
    return WordPair(first, second);
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = <WordPair>{};
  final _customWords = <CustomWordPair>[]; // List untuk kata custom
  final _biggerFont = const TextStyle(fontSize: 18.0, color: Color(0xFF333333));
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<dynamic> _searchResults = []; // Bisa berisi WordPair atau CustomWordPair
  bool _isSearching = false;
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    _generateInitialSuggestions();
  }

  void _generateInitialSuggestions() {
    _suggestions.addAll(generateWordPairs().take(10));
  }

  void _searchWords(String query) {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
      // Gabungkan suggestions dan custom words untuk search
      final allWords = [..._suggestions, ..._customWords.map((cw) => cw.toWordPair()), ...generateWordPairs().take(500)];
      _searchResults = allWords.where((pair) {
        final displayName = pair is CustomWordPair ? pair.asPascalCase : pair.asPascalCase;
        return displayName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildSearchBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _showSearchBar ? 250 : 0,
      height: 40,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF2E7D32).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: _showSearchBar ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search generate random word ...',
            hintStyle: const TextStyle(color: Color(0xFF888888)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF2E7D32)),
              onPressed: () {
                setState(() {
                  _showSearchBar = false;
                  _searchController.clear();
                  _isSearching = false;
                  _searchResults.clear();
                });
              },
            ),
          ),
          style: const TextStyle(color: Color(0xFF333333), fontSize: 14),
          onChanged: _searchWords,
        ),
      ) : const SizedBox(),
    );
  }

  Widget _buildSuggestions() {
    final items = _isSearching ? _searchResults : [..._suggestions, ..._customWords];

    if (_isSearching && items.isEmpty && _searchController.text.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Color(0xFF888888)),
            const SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: const TextStyle(color: Color(0xFF666666), fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lightbulb_outline, size: 48, color: Color(0xFF888888)),
            const SizedBox(height: 16),
            const Text(
              'No suggestions available',
              style: TextStyle(color: Color(0xFF666666), fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              onPressed: _showCreateDialog,
              child: const Text('Create Your First Word'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: items.length + (_isSearching ? 0 : 1),
      itemBuilder: (context, i) {
        if (i == items.length && !_isSearching) {
          return _buildLoadMoreButton();
        }
        
        if (i.isOdd && i < items.length) return const Divider(height: 1, color: Color(0xFFEEEEEE));

        final index = i ~/ 2;
        if (index >= items.length) return const SizedBox();

        final item = items[index];
        final isCustom = item is CustomWordPair;

        return _buildRow(item, isCustom);
      },
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                setState(() {
                  _suggestions.addAll(generateWordPairs().take(10));
                });
              },
              child: const Text('Load More Suggestions'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
                side: const BorderSide(color: Color(0xFF2E7D32)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _showCreateDialog,
              child: const Text('Create Custom Word'),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFFFA000),
                side: const BorderSide(color: Color(0xFFFFA000)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _pushCustomWords,
              child: const Text('View All Custom Words'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(dynamic pair, bool isCustom) {
    final displayName = isCustom ? pair.asPascalCase : pair.asPascalCase;
    final alreadySaved = _saved.any((savedPair) => 
        savedPair.first == (isCustom ? pair.first : pair.first) &&
        savedPair.second == (isCustom ? pair.second : pair.second));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
        border: isCustom 
            ? Border.all(color: const Color(0xFFFFA000).withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: ListTile(
        title: Row(
          children: [
            Text(
              displayName,
              style: _biggerFont,
            ),
            if (isCustom) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA000).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Custom',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFFFA000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCustom)
              IconButton(
                icon: const Icon(Icons.edit, size: 20, color: Color(0xFF2E7D32)),
                onPressed: () => _showEditDialog(pair as CustomWordPair),
                tooltip: 'Edit word',
              ),
            if (isCustom)
              IconButton(
                icon: const Icon(Icons.delete, size: 20, color: Color(0xFFE53935)),
                onPressed: () => _showDeleteDialog(pair as CustomWordPair),
                tooltip: 'Delete word',
              ),
            IconButton(
              icon: Icon(
                alreadySaved ? Icons.favorite : Icons.favorite_border,
                color: alreadySaved ? const Color(0xFFE53935) : const Color(0xFF888888),
              ),
              onPressed: () {
                setState(() {
                  if (alreadySaved) {
                    // Hapus dari saved
                    _saved.removeWhere((savedPair) => 
                        savedPair.first == (isCustom ? pair.first : pair.first) &&
                        savedPair.second == (isCustom ? pair.second : pair.second));
                  } else {
                    if (_saved.length >= 500) {
                      _showMaxLimitDialog();
                    } else {
                      // Tambahkan ke saved (konversi ke WordPair jika custom)
                      final wordPairToSave = isCustom 
                          ? (pair as CustomWordPair).toWordPair()
                          : pair as WordPair;
                      _saved.add(wordPairToSave);
                    }
                  }
                });
              },
              tooltip: alreadySaved ? 'Remove from saved' : 'Save',
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final firstController = TextEditingController();
    final secondController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Create Custom Word',
            style: TextStyle(color: Color(0xFF2E7D32)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstController,
                decoration: const InputDecoration(
                  labelText: 'First Word *',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Tech, Cloud, Smart',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: secondController,
                decoration: const InputDecoration(
                  labelText: 'Second Word (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Hub, Solutions, Labs',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final first = firstController.text.trim();
                final second = secondController.text.trim();
                
                if (first.isNotEmpty) {
                  final newWord = CustomWordPair(first, second);
                  setState(() {
                    _customWords.add(newWord);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${newWord.asPascalCase}" created successfully!'),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(CustomWordPair oldPair) {
    final firstController = TextEditingController(text: oldPair.first);
    final secondController = TextEditingController(text: oldPair.second);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Edit Custom Word',
            style: TextStyle(color: Color(0xFF2E7D32)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstController,
                decoration: const InputDecoration(
                  labelText: 'First Word *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: secondController,
                decoration: const InputDecoration(
                  labelText: 'Second Word (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final first = firstController.text.trim();
                final second = secondController.text.trim();
                
                if (first.isNotEmpty) {
                  final newWord = CustomWordPair(first, second);
                  setState(() {
                    final index = _customWords.indexOf(oldPair);
                    if (index != -1) {
                      _customWords[index] = newWord;
                      
                      // Update juga di saved list jika ada
                      final savedIndex = _saved.toList().indexWhere((savedPair) => 
                          savedPair.first == oldPair.first && 
                          savedPair.second == oldPair.second);
                      
                      if (savedIndex != -1) {
                        _saved.remove(_saved.toList()[savedIndex]);
                        _saved.add(newWord.toWordPair());
                      }
                    }
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Word updated to "${newWord.asPascalCase}"!'),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(CustomWordPair pair) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Custom Word',
            style: TextStyle(color: Color(0xFF2E7D32)),
          ),
          content: Text(
            'Are you sure you want to delete "${pair.asPascalCase}"?',
            style: const TextStyle(color: Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF666666))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _customWords.remove(pair);
                  // Hapus juga dari saved jika ada
                  _saved.removeWhere((savedPair) => 
                      savedPair.first == pair.first && 
                      savedPair.second == pair.second);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('"${pair.asPascalCase}" deleted successfully!'),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _pushCustomWords() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Custom Words (${_customWords.length})'),
              backgroundColor: const Color(0xFFFFA000),
              foregroundColor: Colors.white,
              actions: [
                if (_customWords.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: _showClearAllCustomWordsDialog,
                    tooltip: 'Clear all custom words',
                  ),
              ],
            ),
            body: _customWords.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create_outlined, size: 48, color: Color(0xFF888888)),
                        SizedBox(height: 16),
                        Text(
                          'No custom words created yet',
                          style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap the + button to create your first custom word',
                          style: TextStyle(color: Color(0xFF999999), fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _customWords.length,
                    itemBuilder: (context, index) {
                      final pair = _customWords[index];
                      final alreadySaved = _saved.any((savedPair) => 
                          savedPair.first == pair.first && 
                          savedPair.second == pair.second);

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFFFA000).withOpacity(0.3), width: 1.5),
                        ),
                        child: ListTile(
                          title: Text(
                            pair.asPascalCase,
                            style: _biggerFont,
                          ),
                          subtitle: Text(
                            'First: ${pair.first}${pair.second.isNotEmpty ? ', Second: ${pair.second}' : ''}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20, color: Color(0xFF2E7D32)),
                                onPressed: () => _showEditDialog(pair),
                                tooltip: 'Edit word',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Color(0xFFE53935)),
                                onPressed: () => _showDeleteDialog(pair),
                                tooltip: 'Delete word',
                              ),
                              IconButton(
                                icon: Icon(
                                  alreadySaved ? Icons.favorite : Icons.favorite_border,
                                  color: alreadySaved ? const Color(0xFFE53935) : const Color(0xFF888888),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (alreadySaved) {
                                      _saved.removeWhere((savedPair) => 
                                          savedPair.first == pair.first && 
                                          savedPair.second == pair.second);
                                    } else {
                                      if (_saved.length >= 500) {
                                        _showMaxLimitDialog();
                                      } else {
                                        _saved.add(pair.toWordPair());
                                      }
                                    }
                                  });
                                },
                                tooltip: alreadySaved ? 'Remove from saved' : 'Save to favorites',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  void _showClearAllCustomWordsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Custom Words?'),
          content: const Text('Are you sure you want to delete all custom words? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Hapus juga dari saved jika ada
                  for (var customWord in _customWords) {
                    _saved.removeWhere((savedPair) => 
                        savedPair.first == customWord.first && 
                        savedPair.second == customWord.second);
                  }
                  _customWords.clear();
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close custom words page
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('All custom words deleted successfully!'),
                    backgroundColor: const Color(0xFF2E7D32),
                  ),
                );
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showMaxLimitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Limit Reached',
            style: TextStyle(color: Color(0xFF2E7D32)),
          ),
          content: const Text(
            'You can only save up to 500 generate random word names. '
            'Please remove some saved items to add new ones.',
            style: TextStyle(color: Color(0xFF666666)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Color(0xFF2E7D32))),
            ),
          ],
        );
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = _saved.map(
            (pair) {
              final isCustom = _customWords.any((cw) => 
                  cw.first == pair.first && cw.second == pair.second);
              
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
                subtitle: isCustom 
                    ? const Text('Custom Word', style: TextStyle(color: Color(0xFFFFA000), fontSize: 12))
                    : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCustom)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF2E7D32)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          final customWord = _customWords.firstWhere((cw) => 
                              cw.first == pair.first && cw.second == pair.second);
                          _showEditDialog(customWord);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Color(0xFFE53935)),
                      onPressed: () {
                        setState(() {
                          _saved.remove(pair);
                        });
                        Navigator.of(context).pop();
                        _pushSaved();
                      },
                    ),
                  ],
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions (${_saved.length}/500)'),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              actions: [
                if (_saved.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: _showClearAllDialog,
                    tooltip: 'Clear all saved',
                  ),
              ],
            ),
            body: divided.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 48, color: Color(0xFF888888)),
                        SizedBox(height: 16),
                        Text(
                          'No saved suggestions yet',
                          style: TextStyle(color: Color(0xFF666666), fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView(children: divided),
          );
        },
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Saved?'),
          content: const Text('Are you sure you want to remove all saved suggestions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _saved.clear();
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close saved page
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'generate random word Name Generator',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          _buildSearchBar(),
          _buildSearchIcon(),
          const SizedBox(width: 8),
          IconButton(
            icon: Badge(
              label: Text(_saved.length.toString()),
              backgroundColor: Colors.amber,
              textColor: Colors.black,
              child: const Icon(Icons.favorite, color: Colors.white),
            ),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: _buildSuggestions(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Create Custom Word',
      ),
    );
  }

  Widget _buildSearchIcon() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Tooltip(
        message: 'Search generate random word names',
        child: IconButton(
          icon: Icon(
            _showSearchBar ? Icons.search_off : Icons.search,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showSearchBar = !_showSearchBar;
              if (_showSearchBar) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  _focusNode.requestFocus();
                });
              } else {
                _searchController.clear();
                _isSearching = false;
                _searchResults.clear();
              }
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}