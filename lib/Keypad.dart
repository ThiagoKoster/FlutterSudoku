import 'package:flutter/material.dart';
import 'package:hello_world/SudokuChangeNotifier.dart';
import 'package:provider/provider.dart';

class Keypad extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Table(
      border: TableBorder(
        left: BorderSide(width: 3.0, color: Colors.black),
        top: BorderSide(width: 3.0, color: Colors.black),
      ),
      children: _getTableRows(),
    );
  }

  _getTableRows() {
    return List.generate(1, (index) => TableRow(children: _getRow(index)));
  }

  _getRow(int index) {
    return List.generate(9, (index) {
      return KeyCell(index + 1);
    });
  }
}

//TODO: Mudar a cor da tecla selecionada
class KeyCell extends StatelessWidget {
  int val = 0;
  KeyCell(int val) {
    this.val = val;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Provider.of<SudokuChangeNotifier>(context).getKeyColor(val),
            border: Border(
                right: BorderSide(width: 2.0, color: Colors.black),
                bottom: BorderSide(width: 2.0, color: Colors.black))),
        child: InkResponse(
            onTap: () => {
                  Provider.of<SudokuChangeNotifier>(context, listen: false)
                      .select = this.val
                },
            child: SizedBox(
                height: 30,
                width: 30,
                child: Center(child: Text(val.toString())))));
  }
}
