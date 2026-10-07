import 'package:flutter/widgets.dart';
import 'package:sheen/sheen.dart';

import '../demo.dart';

class InputsPage extends StatefulWidget {
  const InputsPage({super.key});

  @override
  State<InputsPage> createState() => _InputsPageState();
}

class _InputsPageState extends State<InputsPage> {
  final _name = TextEditingController(text: 'Ada Lovelace');
  final _email = TextEditingController(text: 'ada@');
  final _password = TextEditingController();
  final _search = TextEditingController();
  final _code = TextEditingController();
  int _guests = 2;
  bool _alerts = true;
  double _volume = .4, _stars = .6;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _search, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SheenPage(
    title: 'Inputs',
    children: [
      Demo(
        title: 'Text fields',
        child: Column(
          children: [
            SheenTextField(label: 'Full name', controller: _name, autofillHints: const [AutofillHints.name]),
            const SizedBox(height: 12),
            SheenTextField(
              label: 'Email',
              controller: _email,
              error: 'Enter a valid email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            SheenPasswordField(label: 'Password', controller: _password, placeholder: 'At least 8 characters'),
          ],
        ),
      ),
      Demo(
        title: 'Search',
        child: SheenSearchField(controller: _search, hint: 'Search 803 stays by name'),
      ),
      Demo(
        title: 'One-time code',
        note: 'Digits only, with the code from a text message offered by the keyboard.',
        child: SheenCodeField(controller: _code, semanticLabel: 'Enter the 6-digit code', autofocus: false),
      ),
      Demo(
        title: 'Stepper and switch',
        child: SheenListGroup(
          children: [
            SheenListRow(
              title: 'Guests',
              trailing: SheenStepper(
                value: _guests,
                min: 1,
                max: 8,
                decreaseLabel: 'Fewer guests',
                increaseLabel: 'More guests',
                onChanged: (v) => setState(() => _guests = v),
              ),
            ),
            SheenListRow(
              title: 'Price alerts',
              trailing: SheenSwitch(
                value: _alerts,
                semanticLabel: 'Price alerts',
                onChanged: (v) => setState(() => _alerts = v),
              ),
            ),
          ],
        ),
      ),
      Demo(
        title: 'Sliders',
        child: Column(
          children: [
            SheenSlider(value: _volume, onChanged: (v) => setState(() => _volume = v), semanticLabel: 'Volume'),
            SheenSlider(
              value: _stars,
              divisions: 5,
              onChanged: (v) => setState(() => _stars = v),
              semanticLabel: 'Stars',
              semanticFormatter: (v) => '${(v * 5).round()} stars',
            ),
          ],
        ),
      ),
    ],
  );
}
