@isTest
public class TestPostInstallINsights {
	@isTest
    static void testInstallScript() {
      PostInstallInsights p = new PostInstallInsights();
        Test.testInstall(p, null);
        Test.testInstall(p, new Version(1,3), true);
        List<varasi_am__Conf_Category__c> a = [Select id, name from varasi_am__Conf_Category__c where varasi_am__Category_Type__c in ('Account Insight','Tab Visibility')];
        System.assert(a.size()>0,'Records not Created');
      }
}