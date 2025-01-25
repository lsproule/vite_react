import path from 'path'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'
import react from "@vitejs/plugin-react"
import tailwindcss from '@tailwindcss/vite'


export default defineConfig({
  plugins: [
    react(),
    RubyPlugin(),
    tailwindcss()
  ],
  server: {
    watch: {
      usePolling: true
    }
  },
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./app/javascript"),
    },
  },
})

