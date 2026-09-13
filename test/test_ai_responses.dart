import 'package:flutter_test/flutter_test.dart';
import 'package:apdm/services/service_locator.dart';

void main() {
  test('Direct verification of 3 distinct inputs', () async {
    final services = ServiceLocator.instance;
    final profile = services.profileService.profile;
    final memories = services.memoryService.memories;

    final r1 = await services.aiService.generateMultilingualResponse(
      userUtterance: 'Appa, Meenu pathi pesunga.',
      memories: memories,
      profile: profile,
    );
    print('RESPONSE 1: ${r1.text}');

    final r2 = await services.aiService.generateMultilingualResponse(
      userUtterance: 'Appa, Dinesh business eppadi poguthu?',
      memories: memories,
      profile: profile,
    );
    print('RESPONSE 2: ${r2.text}');

    final r3 = await services.aiService.generateMultilingualResponse(
      userUtterance: 'Appa, enakku konjam advice venum.',
      memories: memories,
      profile: profile,
    );
    print('RESPONSE 3: ${r3.text}');

    expect(r1.text.isNotEmpty, isTrue);
    expect(r2.text.isNotEmpty, isTrue);
    expect(r3.text.isNotEmpty, isTrue);
    expect(r1.text, isNot(equals(r2.text)));
    expect(r2.text, isNot(equals(r3.text)));
    expect(r1.text.contains('Meenu'), isTrue);
    expect(r2.text.contains('Dinesh'), isTrue);
    expect(r3.text.contains('Porumai') || r3.text.contains('vaarthai') || r3.text.contains('vazhkai'), isTrue);
  });
}
