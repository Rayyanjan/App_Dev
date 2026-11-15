import 'package:flutter_test/flutter_test.dart';
import 'package:roombook/domain/app_models.dart';

void main() {
  test('domain check accepts IBA emails only', () {
    expect(Validators.isAllowedEmail('x@khi.iba.edu.pk'), true);
    expect(Validators.isAllowedEmail('X@IBA.EDU.PK'), true);
    expect(Validators.isAllowedEmail('x@gmail.com'), false);
  });
}
