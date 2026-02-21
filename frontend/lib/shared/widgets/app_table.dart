import 'package:flutter/material.dart';

/// Simple data table. Uses theme.
class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
  });

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns
            .map((c) => DataColumn(label: Text(c, style: theme.textTheme.titleSmall)))
            .toList(),
        rows: rows
            .map((row) => DataRow(
                  cells: row.map((c) => DataCell(Text(c))).toList(),
                ))
            .toList(),
      ),
    );
  }
}
