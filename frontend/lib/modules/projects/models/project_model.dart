/// Project model. Add fromJson/toJson when wiring API.
class ProjectModel {
  const ProjectModel({
    this.id,
    this.name,
    this.status,
    this.progress = 0,
  });

  final String? id;
  final String? name;
  final String? status;
  final int progress;
}
