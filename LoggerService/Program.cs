using System;

namespace LoggerService {
  public static class Program {
    public static void Main() {
      Logger applicationLogger = Logger.Instance;
      applicationLogger.Info("Приложение успешно запущено");
      applicationLogger.Warning("Обнаружена устаревшая версия конфигурационного файла");
      applicationLogger.Error("Не удалось установить соединение с базой данных");

      bool isSameInstance = applicationLogger == Logger.Instance;

      Console.WriteLine();
      Console.WriteLine($"Один и тот же экземпляр: {isSameInstance}");
    }
  }
}