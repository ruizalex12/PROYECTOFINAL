import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_final_360/models/academic_entities.dart';

void main() {
  test('los roles se interpretan de forma segura', () {
    expect(roleFromString('admin'), UserRole.admin);
    expect(roleFromString('administrador'), UserRole.admin);
    expect(roleFromString('docente'), UserRole.docente);
    expect(roleFromString('estudiante'), UserRole.estudiante);
  });
  test('calcula promedio y asistencia del estudiante', () {
    const assignment = CourseAssignment(
        id: 'a',
        courseId: 'c',
        teacherId: 't',
        subjectId: 's',
        periodId: 'p',
        courseName: 'Curso',
        subjectName: 'Materia',
        teacherName: 'Docente',
        periodName: '2026-I');
    const data = StudentCourseData(assignment: assignment, grades: [
      {'nota': 80},
      {'nota': 90}
    ], attendance: [
      {'estado': 'Presente'},
      {'estado': 'Ausente'},
      {'estado': 'Justificado'}
    ], announcements: []);
    expect(data.average, 85);
    expect(data.attendancePercent, closeTo(66.666, 0.01));
  });
  test('cursos sin datos devuelven cálculos en cero', () {
    const assignment = CourseAssignment(
        id: 'a',
        courseId: 'c',
        teacherId: 't',
        subjectId: 's',
        periodId: 'p',
        courseName: 'Curso',
        subjectName: 'Materia',
        teacherName: 'Docente',
        periodName: '2026-I');
    const data = StudentCourseData(
        assignment: assignment, grades: [], attendance: [], announcements: []);
    expect(data.average, 0);
    expect(data.attendancePercent, 0);
  });
}
