import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'SudokuChangeNotifier.dart';

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
