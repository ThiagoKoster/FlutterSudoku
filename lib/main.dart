import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: SudokuChangeNotifier(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage({Key key, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[SudokuBoard()],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Provider.of<SudokuChangeNotifier>(context, listen: false)
                .resetBoard(),
        tooltip: 'ResetBoard',
        child: Icon(Icons.add),
      ),
    );
  }
}

class SudokuBoard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        left: BorderSide(width: 3.0, color: Colors.black),
        top: BorderSide(width: 3.0, color: Colors.black),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: _getTableRows(),
    );
  }

  List<TableRow> _getTableRows() {
    return List.generate(9, (int rowNumber) {
      return TableRow(children: _getRow(rowNumber));
    });
  }

  List<Widget> _getRow(int rowNumber) {
    return List.generate(9, (int colNumber) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            right: BorderSide(
              width: (colNumber % 3 == 2) ? 3.0 : 1.0,
              color: Colors.black,
            ),
            bottom: BorderSide(
              width: (rowNumber % 3 == 2) ? 3.0 : 1.0,
              color: Colors.black,
            ),
          ),
        ),
        child: SudokuCell(rowNumber, colNumber),
      );
    });
  }
}

class SudokuCell extends StatelessWidget {
  final int row, col;
  final List<SudokuCell> neighbors = List<SudokuCell>();
  SudokuCell(this.row, this.col);

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      enableFeedback: true,
      onTap: () {
        Provider.of<SudokuChangeNotifier>(context, listen: false)
            .setBoardCell(this.row, this.col);
      },
      child: SizedBox(
        width: 30,
        height: 30,
        child: Selector<SudokuChangeNotifier, String>(
          builder: (_, data, __) {
            debugPrint('Seting \'$data\' to ($row,$col)');
            return Center(
              child: Text(data),
            );
          },
          selector: (_, sudokuChangeNotifier) =>
              sudokuChangeNotifier.getBoardCell(this.row, this.col),
        ),
      ),
    );
  }
}

class SudokuChangeNotifier with ChangeNotifier {
  List<List<int>> board = List.generate(9, (_) => List.generate(9, (_) => 0));
  final generator = SudokuGenerator();

  String getBoardCell(int row, int col) {
    return this.board[row][col] == 0 ? '' : this.board[row][col].toString();
  }

  void setBoardCell(int row, int col) {
    this.board[row][col] = 9;
    notifyListeners();
  }

  void generateBoard() {
    generator.generateSudoku(this.board);
    notifyListeners();
  }

  void resetBoard() {
    debugPrint('Reseting board...');
    this.board = List.generate(9, (_) => List.generate(9, (_) => 0));
    notifyListeners();
  }
}

class SudokuGenerator {
  void generateSudoku(List<List<int>> board) {}
}
