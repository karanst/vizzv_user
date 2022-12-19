
import 'package:flutter/material.dart';
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({Key? key}) : super(key: key);

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

/*class _ExpandableFabState extends State<ExpandableFab> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}*/

class _ExpandableFabState extends State<ExpandableFab> {
  bool _open = false;

  @override
  /*void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
  }*/

  void _toggle() {
    setState(() {
      _open = !_open;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          //_buildTapToCloseFab(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  /*Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56.0,
      height: 56.0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }*/

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.bottomCenter,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            onPressed:() {
              _showMyDialog(context);
              },
            child: InkWell(
              onTap: (){
                _showMyDialog(context);
               /* AlertDialog(
                  title: Text('AlertDialog Title'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        Text('This is a demo alert dialog.'),
                        Text('Would you like to approve of this message?'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Allow'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Block'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );*/
              },
                child: Text("Menu")),
          ),
        ),
      ),
    );
  }
}

Future<void> _showMyDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: true, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Surendra Singh'),
        content: SingleChildScrollView(
          child: ListView(
            children:[
              Text('This is a demo alert dialog.'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        /*actions: <Widget>[
          TextButton(
            child: Text('Allow'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Back'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],*/
      );
    },
  );
}


