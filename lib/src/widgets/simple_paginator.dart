import 'package:flutter/material.dart';

/// Minimal replacement for `flutter_paginator` to keep legacy screens working.
///
/// This implementation only loads the **first page** via [pageLoadFuture]
/// and renders all items in a simple `ListView.builder`.
/// The `changeState` method just reloads page 1.
class Paginator extends StatefulWidget {
  final Future<dynamic> Function(int page) pageLoadFuture;
  final List<dynamic> Function(dynamic data) pageItemsGetter;
  final Widget Function(dynamic item, int index) listItemBuilder;
  final Widget Function() loadingWidgetBuilder;
  final Widget Function(dynamic data, VoidCallback retry) errorWidgetBuilder;
  final Widget Function(dynamic data) emptyListWidgetBuilder;
  final int Function(dynamic data) totalItemsGetter;
  final bool Function(dynamic data) pageErrorChecker;
  final ScrollPhysics? scrollPhysics;

  const Paginator.listView({
    Key? key,
    required this.pageLoadFuture,
    required this.pageItemsGetter,
    required this.listItemBuilder,
    required this.loadingWidgetBuilder,
    required this.errorWidgetBuilder,
    required this.emptyListWidgetBuilder,
    required this.totalItemsGetter,
    required this.pageErrorChecker,
    this.scrollPhysics,
  }) : super(key: key);

  @override
  PaginatorState createState() => PaginatorState();
}

class PaginatorState extends State<Paginator> {
  bool _isLoading = true;
  bool _hasError = false;
  dynamic _rawData;
  List<dynamic> _items = [];

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  /// Keeps the same API that legacy code expects.
  void changeState({
    required Future<dynamic> Function(int page) pageLoadFuture,
    bool resetState = false,
  }) {
    // For now we ignore [pageLoadFuture] override and always use page 1
    // with the widget's configured callbacks.
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final data = await widget.pageLoadFuture(1);
      final hasError = widget.pageErrorChecker(data);
      if (hasError) {
        setState(() {
          _rawData = data;
          _hasError = true;
          _isLoading = false;
        });
        return;
      }
      final items = widget.pageItemsGetter(data);
      setState(() {
        _rawData = data;
        _items = items;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.loadingWidgetBuilder();
    }

    if (_hasError) {
      return widget.errorWidgetBuilder(_rawData, _loadFirstPage);
    }

    if (_items.isEmpty) {
      return widget.emptyListWidgetBuilder(_rawData);
    }

    return ListView.builder(
      physics: widget.scrollPhysics,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return widget.listItemBuilder(_items[index], index);
      },
    );
  }
}

