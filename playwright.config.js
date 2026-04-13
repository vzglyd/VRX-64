module.exports = {
  use: {
    browserName: 'chromium',
    launchOptions: {
      args: [
        '--enable-unsafe-webgpu',
        '--use-angle=swiftshader',
        '--disable-gpu-sandbox',
      ],
    },
  },
  timeout: 30_000,
};
