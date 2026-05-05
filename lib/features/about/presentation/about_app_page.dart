import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('О приложении'),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: FutureBuilder<String>(
          future: rootBundle.loadString('README.md'),
          builder: (context, snapshot) {
            final content = snapshot.data;

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Тестовое задание "Камера" для Aquafon',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (snapshot.connectionState != ConnectionState.done)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (snapshot.hasError || content == null)
                    const Text('Не удалось загрузить README.md.')
                  else
                    Expanded(
                      child: Markdown(
                        data: content,
                        padding: EdgeInsets.zero,
                        selectable: true,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
