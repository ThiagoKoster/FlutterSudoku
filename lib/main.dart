import 'dart:math';

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
  int val = 0;
  List<int> neighborsValues;
  SudokuCell(this.row, this.col);

  set neighbors(List<int> neighbors) {
    this.neighborsValues = neighbors;
  }

  List<int> get neighbors {
    return neighborsValues;
  }

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
  List<List<SudokuCell>> board = List.generate(
      9, (col) => List.generate(9, (row) => SudokuCell(row, col)));

  String getBoardCell(int row, int col) {
    return this.board[row][col].val == 0
        ? ''
        : this.board[row][col].val.toString();
  }

  void setBoardCell(int row, int col) {
    this.board[row][col].val = 9;
    debugPrint(this.board[row][col].neighbors.toString());
    notifyListeners();
  }

  void generateSudokuAsync() {
    debugPrint('Generating board...');

    solve(0, 0);
    notifyListeners();

    debugPrint('Done...');
    debugPrint((this.board[0].map((e) => e.val)).toString());
  }

  List<int> randomNumberList() {
    Random rdn = new Random();
    List<int> list = new List<int>();
    for (int i = 0; i < 9; i++) {
      int n = rdn.nextInt(9) + 1;
      while (list.contains(n)) {
        n = rdn.nextInt(9) + 1;
      }
      list.add(n);
    }

    return list;
  }

  bool solve(int row, int col) {
    if (col == 9) return true;

    var digits = randomNumberList();
    //TODO: Sempre gera o mesmo sudoku, pois pega o valor começando com 1. O ideal seria ser aleatório.
    for (int i = 0; i < 9; i++) {
      this.board[row][col].val = digits[i];

      if (isValid(row, col)) {
        if (row == 8) {
          //If reached at last row then move to starting of next column
          if (solve(0, col + 1)) return true;
        } else {
          if (solve(row + 1, col)) return true;
        }
      }
    }

    this.board[row][col].val = 0;
    return false;
  }

//Function to check if the current placement in
  //board[row][column] is valid or not
  bool isValid(int row, int column) {
    //Checking he column (horizontal)
    for (int i = 0; i < 9; i++) {
      if ((this.board[row][i].val == this.board[row][column].val) &&
          (i != column)) return false;
    }
    //Checking the row (vertical)
    for (int i = 0; i < 9; i++) {
      if ((this.board[i][column].val == this.board[row][column].val) &&
          (i != row)) return false;
    }
    //Computing starting point of the current Grid
    int sr = (row ~/ 3) * 3;
    int sc = (column ~/ 3) * 3;
    //Checking the grid (3x3)
    for (int i = sr; i < sr + 3; i++) {
      for (int j = sc; j < sc + 3; j++) {
        if (this.board[row][column].val == this.board[i][j].val &&
            (row != i) &&
            (column != j)) return false;
      }
    }
    return true;
  }

  List<int> getCellNeighbours(int row, int col) {
    //TODO: Melhorar como está sendo pegos os vizinhos.
    var neighbours = new List<int>();
    for (int i = 0; i < 9; i++) {
      if (i != row) neighbours.add(this.board[i][col].val);
      if (i != col) neighbours.add(this.board[row][i].val);
    }

    int sqx0 = col ~/ 3 * 3;
    int sqx1 = sqx0 + 3;

    int sqy0 = row ~/ 3 * 3;
    int sqy1 = sqy0 + 3;

    for (int i = sqy0; i < sqy1; i++) {
      for (int j = sqx0; j < sqx1; j++) {
        if (i != row || j != col) neighbours.add(this.board[i][j].val);
      }
    }

    return neighbours;
  }

  void resetBoard() {
    debugPrint('Reseting board...');
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        this.board[i][j].val = 0;
      }
    }
    notifyListeners();

    generateSudokuAsync();
  }
}
