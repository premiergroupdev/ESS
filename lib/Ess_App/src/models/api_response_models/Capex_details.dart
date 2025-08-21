class ExpenseModel {
  final List<Expensedetail> expenses;

  ExpenseModel({required this.expenses});

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      expenses: (json['Expenses'] as List)
          .map((e) => Expensedetail.fromJson(e))
          .toList(),
    );
  }
}

class Expensedetail {
  final String copexId;
  final String empCode;

  final String memberName;
  final String memberDesignation;
  final String branch;
  final String postedDate;
  final String capexType;
  final String cordStatus;
  final String? priceVerification;
  final String hodStatus;
  final String ceoStatus;
  final String deptHeadStatus;
  final String gmStatus;
  final String phonenumber;

  final String grandtotal;
  final List<CopexLog> copexLogs;
  final List<CopexItem> copexItems;

  Expensedetail({
    required this.copexId,
    required this.empCode,
    required this.memberName,
    required this.memberDesignation,
    required this.branch,
    required this.postedDate,
    required this.capexType,
    required this.cordStatus,
    required this.ceoStatus,
    this.priceVerification,
    required this.hodStatus,

    required this.deptHeadStatus,
    required this.gmStatus,
    required this.copexLogs,
    required this.copexItems,
    required this.grandtotal,
    required this.phonenumber
  });

  factory Expensedetail.fromJson(Map<String, dynamic> json) {
    return Expensedetail(

      copexId: json['copex_id'],
      phonenumber: json['member_mobile'],
      empCode: json['emp_code'],
      memberName: json['member_name'],
      memberDesignation: json['member_designation'],
      branch: json['branch'],
      postedDate: json['posted_date'],
      capexType: json['capex_type'],
      cordStatus: json['cord_status'],
      ceoStatus: json['ceo_status'].toString(),

      priceVerification: json['price_verification'],
      hodStatus: json['hod_status'],
      grandtotal: json['grant_total'],
      deptHeadStatus: json['dept_head_status'],
      gmStatus: json['gm_status'],
      copexLogs: (json['copex_logs'] as List)
          .map((log) => CopexLog.fromJson(log))
          .toList(),
      copexItems: (json['copex_items'] as List)
          .map((item) => CopexItem.fromJson(item))
          .toList(),
    );
  }
}

class CopexLog {
  final String remarks;
  final String username;
  final String postedDate;

  CopexLog({
    required this.remarks,
    required this.username,
    required this.postedDate,
  });

  factory CopexLog.fromJson(Map<String, dynamic> json) {
    return CopexLog(
      remarks: json['remarks'],
      username: json['username'],
      postedDate: json['posted_date'].toString(),
    );
  }
}

class CopexItem {
  final String productid;
  final String itemName;
  final String specs;

  final String is_exp;
  final String branchRequested;
  final String price;
  final String qty;
  final int totalPriceApproved;
  final List<Quotation> quotationsArr;

  CopexItem({
    required this.productid,
    required this.itemName,
    required this.specs,
    required this.is_exp,
    required this.branchRequested,
    required this.price,
    required this.qty,
    required this.totalPriceApproved,
    required this.quotationsArr,
  });

  factory CopexItem.fromJson(Map<String, dynamic> json) {
    return CopexItem(
      productid: json['copex_product_id'],
      itemName: json['item_name'],
      is_exp: json['is_exp'].toString(),
      specs: json['specs'].toString(),
      branchRequested: json['branch_requested'] ?? '',
      price: json['price'].toString(),
      qty: json['qty'],
      totalPriceApproved: json['total_price_approved'],
      quotationsArr: (json['quotations_arr'] as List)
          .map((q) => Quotation.fromJson(q))
          .toList(),
    );
  }
}

class Quotation {
  final String quoteStatus;
  final String vendorName;
  final String quot_id;
  final String reason;
  final String fileUrl;
  final String vendorPrice;
  final String qty;
  final int totalPrice;

  Quotation({
    required this.quoteStatus,
    required this.vendorName,
    required this.quot_id,
    required this.reason,
    required this.fileUrl,
    required this.vendorPrice,
    required this.qty,
    required this.totalPrice,
  });

  factory Quotation.fromJson(Map<String, dynamic> json) {
    return Quotation(
        quot_id: json['quote_id'],
      reason: json['rank'],
      quoteStatus: json['quote_status'],
      vendorName: json['vendor_name'],
      fileUrl: json['file_url'],
      vendorPrice: json['vendor_price'],
      qty: json['qty'],
      totalPrice: json['total_price'],
    );
  }
}
