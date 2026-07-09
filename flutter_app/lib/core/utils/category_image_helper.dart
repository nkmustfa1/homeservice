String getCategoryImage(String categoryName) {
  switch (categoryName.trim().toLowerCase()) {
    case 'تنظيف':
      return 'assets/images/services/cleaning_image.png';
    case 'سباكة':
      return 'assets/images/services/plumbing_image.png';
    case 'كهرباء':
      return 'assets/images/services/electrical_image.png';
    case 'طلاء':
      return 'assets/images/services/painter.jpg';
    case 'نقل':
      return 'assets/images/services/movement.jpeg';
    case 'نجارة':
      return 'assets/images/services/carpenter.jpg';
    case 'صيانة اجهزة':
      return 'assets/images/services/ac.jpg';
    case 'صالون':
      return 'assets/images/services/salon.jpg';
    case 'طبخ':
      return 'assets/images/services/cooking.jpeg';
    default:
      return 'assets/images/services/default_image.png';
  }
}
