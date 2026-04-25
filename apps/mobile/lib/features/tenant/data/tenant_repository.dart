import '../../../core/api/api_models.dart';
import '../../../core/api/delego_json.dart';
import '../../../core/network/api_client.dart';

class TenantRepository {
  TenantRepository(this._apiClient);

  final ApiClient _apiClient;

  /// Returns Prisma `Tenant` rows with nested `organizations.workspaces` (unchanged JSON tree).
  Future<List<Map<String, dynamic>>> listTenants() async {
    final response = await _apiClient.get('/tenant');
    final body = response.data;
    if (body is! List) {
      throw const FormatException('GET /tenant must return a JSON array');
    }
    return body.map((e) => asStringKeyedMap(e, 'GET /tenant[]')).toList();
  }

  Future<OrganizationDto> createOrganization({
    required String tenantId,
    required String name,
  }) async {
    final response = await _apiClient.post(
      '/tenant/$tenantId/organizations',
      data: {'name': name},
    );
    return OrganizationDto.fromJson(asStringKeyedMap(response.data, 'POST /tenant/:tenantId/organizations'));
  }

  Future<WorkspaceDto> createWorkspace({
    required String organizationId,
    required String name,
  }) async {
    final response = await _apiClient.post(
      '/tenant/organizations/$organizationId/workspaces',
      data: {'name': name},
    );
    return WorkspaceDto.fromJson(
      asStringKeyedMap(response.data, 'POST /tenant/organizations/:organizationId/workspaces'),
    );
  }
}
