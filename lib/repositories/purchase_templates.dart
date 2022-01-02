import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/models/purchase_template.dart';
import 'package:consumer_basket/models/purchase_template_item.dart';

class PurchaseTemplatesRepository extends DbRepository<PurchaseTemplate> {

  static const String columnDate = "creation_date";

  PurchaseTemplatesRepository(){
    super.init(
      "purchase_templates",
      () => PurchaseTemplate(),
      [
        DbField<PurchaseTemplate,String?>(
          "title", "TEXT",
          (PurchaseTemplate item) => item.title,
          (PurchaseTemplate item, String? title) => item.title = title ),
        DbField<PurchaseTemplate,String?>(
          columnDate, "DATE",
          (PurchaseTemplate item) => item.creationDate.toString(),
          (PurchaseTemplate item, String? date) {
            if(date != null) {
              item.creationDate = DateTime.parse(date);
            }
          },
          index: true
        ),
        DbField<PurchaseTemplate,String?>(
          "image_path", "TEXT",
          (PurchaseTemplate item) => item.imagePath,
          (PurchaseTemplate item, String? imagePath) => item.imagePath = imagePath),
        DependentDbField<PurchaseTemplate, PurchaseTemplateItem>(
          (PurchaseTemplate item) => item.items
        )
      ]
    );
  }

  Future<List<PurchaseTemplate>> getOrderedByDate([Ordering? ordering]) async{
    return await getOrdered(columnDate, ordering: ordering);
  }
}
