import 'package:analyzer/instrumentation/file_instrumentation.dart';
import 'package:analyzer/instrumentation/instrumentation.dart';

final class LoggerUtil {
  LoggerUtil({required String fileName}) {
    instrumentationLogAdapter = InstrumentationLogAdapter(
      FileInstrumentationLogger('$fileName.log'),
    );
  }

  late final InstrumentationLogAdapter instrumentationLogAdapter;

  void log(String message) {
    instrumentationLogAdapter.logInfo(message);
  }

  void logError(String message) {
    instrumentationLogAdapter.logError(message);
  }

  void logException(Object exception, [StackTrace? stackTrace]) {
    instrumentationLogAdapter.logException(exception, stackTrace);
  }
}
