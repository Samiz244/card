import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// CardModel class definition
class CardModel {
  final int id;
  final String imagePath;
  bool isFlipped;
  bool isMatched;

  CardModel({
    required this.id,
    required this.imagePath,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

// GameState class to manage game state
class GameState extends ChangeNotifier {
  List<CardModel> _cards = [];
  List<CardModel> get cards => _cards;

  CardModel? _firstCard; // Track the first card that was flipped
  CardModel? _secondCard; // Track the second card that was flipped

  GameState() {
    _initializeGame();
  }

  void _initializeGame() {
    final List<String> cardImages = [
      'https://via.placeholder.com/150/FF5733/FFFFFF?text=1',
      'https://via.placeholder.com/150/33FF57/FFFFFF?text=2',
      'https://via.placeholder.com/150/3357FF/FFFFFF?text=3',
      'https://via.placeholder.com/150/FFFF33/FFFFFF?text=4',
    ];

    // Create pairs of cards
    _cards = [];
    for (int i = 0; i < cardImages.length; i++) {
      _cards.add(CardModel(id: i, imagePath: cardImages[i])); // Add the first card
      _cards.add(CardModel(id: i + cardImages.length, imagePath: cardImages[i])); // Add the second card
    }

    _cards.shuffle(); // Shuffle the cards
    notifyListeners();
  }

  void flipCard(CardModel card) {
    if (!card.isMatched && card != _firstCard) {
      card.isFlipped = true; // Flip the card face up
      notifyListeners();

      if (_firstCard == null) {
        // First card flipped
        _firstCard = card;
      } else {
        // Second card flipped
        _secondCard = card;
        _checkForMatch();
      }
    }
  }

  void _checkForMatch() {
    if (_secondCard != null && _firstCard != null) {
      if (_firstCard!.imagePath == _secondCard!.imagePath) {
        // Cards match
        _firstCard!.isMatched = true;
        _secondCard!.isMatched = true;
        // Reset the tracking cards after the match
        _firstCard = null;
        _secondCard = null;
      } else {
        // Cards do not match, flip them back automatically after a delay
        Future.delayed(Duration(seconds: 1), () {
          _firstCard!.isFlipped = false; // Flip first card back
          _secondCard!.isFlipped = false; // Flip second card back
          // Reset the tracking cards after the check
          _firstCard = null;
          _secondCard = null;
          notifyListeners(); // Notify listeners to rebuild UI
        });
      }
    }
  }
}

// CardWidget to display each card with flip animation
class CardWidget extends StatelessWidget {
  final CardModel card;
  final VoidCallback onTap;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(
              card.isFlipped
                  ? card.imagePath
                  : 'https://via.placeholder.com/150/CCCCCC/FFFFFF?text=BACK', // Back image
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

// GameScreen widget
class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Card Matching Game')),
      body: Consumer<GameState>(
        builder: (context, gameState, child) {
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Change to 6 for a 6x6 grid
              childAspectRatio: 1.0,
            ),
            itemCount: gameState.cards.length,
            itemBuilder: (context, index) {
              final card = gameState.cards[index];
              return CardWidget(
                card: card,
                onTap: () {
                  gameState.flipCard(card);
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Main function to run the app
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => GameState(),
      child: MyApp(),
    ),
  );
}

// MyApp widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameScreen(),
    );
  }
}