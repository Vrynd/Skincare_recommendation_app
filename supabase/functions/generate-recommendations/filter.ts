export function runFilterF1(product: any, avoidedIngredientIds: string[]): boolean {
  if (!avoidedIngredientIds || avoidedIngredientIds.length === 0) {
    return true; // Safe
  }

  const productIngredientIds = product.product_ingredients?.map((pi: any) => pi.ingredient_id) || [];
  
  // Jika produk memiliki bahan yang terdaftar di avoidedIngredientIds, maka produk tersebut tidak aman.
  const isUnsafe = productIngredientIds.some((id: string) => avoidedIngredientIds.includes(id));
  
  return !isUnsafe;
}
