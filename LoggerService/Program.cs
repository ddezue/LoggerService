using System;

namespace LoggerService {
  public static class Program {
    public static void Main() {
      Logger applicationLogger = Logger.Instance;
      applicationLogger.Info("Application started successfully");
      applicationLogger.Warning("Obsolete version of configuration file detected");
      applicationLogger.Error("Failed to establish database connection");

      bool isSameInstance = applicationLogger == Logger.Instance;
      Console.WriteLine();
      Console.WriteLine($"Is the same instance: {isSameInstance}");
    }
  }
}