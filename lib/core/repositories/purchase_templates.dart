import 'package:consumer_basket/core/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/core/base/repositories/db_repository.dart';
import 'package:consumer_basket/core/base/repositories/db_field.dart';
import 'package:consumer_basket/core/models/purchase_template.dart';
import 'package:consumer_basket/core/models/purchase_template_item.dart';

class PurchaseTemplatesRepository extends DbRepository<PurchaseTemplate> {

  static const String columnDate = "creation_date";

  PurchaseTemplatesRepository(){
    super.init(
      "purchase_templates",
      () => PurchaseTemplate(),
      [
        DbField<PurchaseTemplate,String?>(
            columnName: "title",
            sqlType: "TEXT",
            getter: (PurchaseTemplate item) => item.title,
            setter: (PurchaseTemplate item, String? title) => item.title = title ),
        DbField<PurchaseTemplate,String?>(
            columnName: columnDate,
            sqlType: "DATE",
            getter: (PurchaseTemplate item) => item.creationDate.toString(),
            setter: (PurchaseTemplate item, String? date) {
              if(date != null) {
                item.creationDate = DateTime.parse(date);
              }
            },
            index: true
        ),
        DbField<PurchaseTemplate,String?>(
            columnName: "image_path",
            sqlType: "TEXT",
            getter: (PurchaseTemplate item) => item.imagePath,
            setter: (PurchaseTemplate item, String? imagePath) => item.imagePath = imagePath),
        DependentMapField<PurchaseTemplate, PurchaseTemplateItem>(
          mapGetter: (PurchaseTemplate item) => item.items
        )
      ]
    );
  }

  Future<List<PurchaseTemplate>> getOrderedByDate([Ordering? ordering]) async{
    return await getOrdered(columnDate, ordering: ordering);
  }
}
