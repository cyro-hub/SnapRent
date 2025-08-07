String formatPrice(num price) {
  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed((price % 1000000 == 0) ? 0 : 2)}mil';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed((price % 1000 == 0) ? 0 : 2)}k';
  } else {
    return price.toString();
  }
}
