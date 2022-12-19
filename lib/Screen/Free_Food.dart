import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:flutter/material.dart';

class FreeFoodPage extends StatefulWidget {
  const FreeFoodPage({Key? key}) : super(key: key);

  @override
  State<FreeFoodPage> createState() => _FreeFoodPageState();
}

class _FreeFoodPageState extends State<FreeFoodPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
      ),
    );
  }
}
