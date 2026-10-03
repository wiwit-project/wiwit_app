import 'package:material_ui/material_ui.dart';

import '../../shared/components/header_text.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppBarText('Transactions'),
                const SizedBox(height: 16),
                // Add your transaction list or other widgets here
              ],
            ),
          ),
        ),
      ),
    );
  }
}
