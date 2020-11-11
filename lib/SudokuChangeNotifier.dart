import 'dart:math';

import 'package:flutter/material.dart';

import 'SudokuCell.dart';

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
    for (int i = 0; i < 9; i++) {
      this.board[row][col].val = digits[i];
      notifyListeners();
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
    //Checking the column (horizontal)
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
