
export default function App() {

  return (
    <div className="flex bg-[#242424] gap-12 text-white h-screen flex-col justify-center items-center mx-auto w-screen">
      <div className="flex text-3xl">
        <a href="https://guides.rubyonrails.org/index.html" target="_blank">
          <img
            src="/images/rails.svg"
            className="logo rails"
            alt="Rails logo"
          />
        </a>
        <a href="https://react.dev" target="_blank">
          <img
            src="/images/react.svg"
            className="logo react"
            alt="React logo"
          />
        </a>
        <a href="https://vite.dev" target="_blank">
          <img src="/images/vite.svg" className="logo" alt="Vite logo" />
        </a>
      </div>
      <h1 className="text-4xl font-bold">
        <span className="text-[#CC0000]">Rails </span>
        + <span className="text-[#61dafb]">React </span>
        + <span className="text-[#646cff]">Vite</span>
      </h1>
      <div className="card flex flex-col items-center">
        <p>
          Edit <code>app/javascript/components/App.tsx</code> and save to test
          HMR
        </p>
      </div>
      <p className="text-[#888]">
        Click on the Rails, Vite and React logos to learn more
      </p>
    </div>
  );
}
