
import "dart:io";

void main() async {
  final Map<String, String> replacements = {
    "../../lib/view/sale/daily_route_view.dart": "SaleTuyNStateList,DailyRouteView",
    "../../lib/view/manager/store_list_view.dart": "ManagerQuNLCAHNgStateList,StoreListView",
    "../../lib/view/manager/route_list_view.dart": "ManagerQuNLTuyNStateList,RouteListView",
    "../../lib/view/manager/route_detail_view.dart": "ManagerQuNLTuyNStateTOChiTiT,RouteDetailView",
    "../../lib/view/manager/edit_route.dart": "ManagerQuNLTuyNStateDanhSChCAHNg,EditRouteView",
    "../../lib/view/manager/route_support.dart": "ManagerQuNLTuyNStateTuyNHTr,RouteSupportView",
    "../../lib/view/manager/choose_sale.dart": "ManagerQuNLTuyNStateChNNhNViN,ChooseSaleView",
    "../../lib/view/manager/create_store_view.dart": "ManagerQuNLCAHNgStateCreateEdit,CreateStoreView",
  };
  
  for (var entry in replacements.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) continue;
    
    final pair = entry.value.split(",");
    final oldName = pair[0];
    final newName = pair[1];
    
    var content = await file.readAsString();
    content = content.replaceAll(oldName, newName);
    await file.writeAsString(content);
    print("Renamed $oldName to $newName in ${file.path}");
  }
}

