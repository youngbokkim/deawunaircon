/// 견적서 API 서버 주소. (현재 프로젝트는 Firebase 사용으로 미사용)
const String kEstimateApiBaseUrl = String.fromEnvironment(
  'ESTIMATE_API_URL',
  defaultValue: 'http://localhost:3000',
);
