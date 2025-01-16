import path from 'path'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from "@vitejs/plugin-react"

export default defineConfig({
  plugins: [
    react(),
    RubyPlugin(),
  ],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./app/javascript"),
    },
  },
})

