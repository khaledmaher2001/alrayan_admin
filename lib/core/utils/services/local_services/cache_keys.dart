import 'cache_helper.dart';

class CacheKeysManger {
  static bool onBoardingStatus() =>
      CacheHelper.getData(key: 'onBoarding') ?? false;
  static String tokenStatus() =>
      CacheHelper.getData(key: 'token') ?? "";
  static String? getUserLanguageFromCache() =>
      CacheHelper.getData(key: 'language')?? "ar";

  static void addToRemoveFromFavorites(int id) async {
    var list = getFavorites();
    if (list.contains(id.toString())) {
      list.remove(id.toString());
    } else {
      list.add(id.toString());
    }
    await CacheHelper.saveData(key: 'favorites', value: list);
  }

  static List<String> getFavorites() {
    return CacheHelper.getListOFData(key: 'favorites') ?? [];
  }

  static void setFavoriteList(List<String> favoriteProducts) async {
    await CacheHelper.saveData(key: 'favorites', value: favoriteProducts);
  }
  static void addToRemoveFromCart(int id) async {
    var list = getCart();
    if (list.contains(id.toString())) {
      list.remove(id.toString());
    } else {
      list.add(id.toString());
    }
    await CacheHelper.saveData(key: 'cart', value: list);
  }

  static List<String> getCart() {
    return CacheHelper.getListOFData(key: 'cart') ?? [];
  }

  static void setCartList(List<String> favoriteProducts) async {
    await CacheHelper.saveData(key: 'cart', value: favoriteProducts);
  }

  static void addRemoveLikePosts(int id) async {
    var list = getLikes();
    var listl = getDislikes();
    if (list.contains(id.toString())) {
      list.remove(id.toString());
    } else {
      if (listl.contains(id.toString())) {
        listl.remove(id.toString());
      }
      list.add(id.toString());
    }
    await
    {
      CacheHelper.saveData(key: 'likes', value: list),
      CacheHelper.saveData(key: 'dislikes', value: listl)
    };
  }

  static List<String> getLikes() {
    return CacheHelper.getListOFData(key: 'likes') ?? [];
  }

  static void setLikes(List<String> likesPosts) async {
    await CacheHelper.saveData(key: 'likes', value: likesPosts);
  }

  static void addRemoveDislikePosts(int id) async {
    var list = getDislikes();
    var listl = getLikes();
    if (list.contains(id.toString())) {
      list.remove(id.toString());
    } else {
      if (listl.contains(id.toString())) {
        listl.remove(id.toString());
      }
      list.add(id.toString());
    }
    await
    {
      CacheHelper.saveData(key: 'likes', value: listl),
    CacheHelper.saveData(key: 'dislikes', value: list)
    };


  }

  static List<String> getDislikes() {
    return CacheHelper.getListOFData(key: 'dislikes') ?? [];
  }

  static void setDislikes(List<String> likesPosts) async {
    await CacheHelper.saveData(key: 'dislikes', value: likesPosts);
  }
}
