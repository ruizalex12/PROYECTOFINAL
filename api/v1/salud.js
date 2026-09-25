export function GET() {
  return Response.json({
    estado: 'ok',
    servicio: 'SFM Tarija',
    version: '1.0',
  });
}
