import '../entities/post.dart';
import '../repositories/post_repository.dart';

class GetPosts {
  final PostRepository repository;
  const GetPosts(this.repository);

  Future<List<Post>> call() => repository.getPosts();
}