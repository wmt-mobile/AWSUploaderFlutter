import "./globals.css";
import cx from "classnames";
import { sfPro, inter } from "./fonts";
import { dir } from "i18next";
import { Metadata } from "next";
import dynamic from "next/dynamic";
import NextTopLoader from "nextjs-toploader";
import { BiArrowToTop } from "react-icons/bi";
import GoogleAnalytics from "@/components/shared/google-analytics";
import CookieBanner from "@/components/shared/cookie-banner";
import ScrollToTop from "@/components/layout/scroll-to-top";
import Footer from "@/components/layout/footer";
import { languages } from "@/i18n/settings";
import { basePath } from "@/constants";
import { Providers } from "./providers";
import Particles from "./particles";

// 是否显示背景特效
const NEXT_PUBLIC_SHOW_PARTICLES = process.env.NEXT_PUBLIC_SHOW_PARTICLES;

const Header = dynamic(() => import("@/components/layout/header"), {
  ssr: false,
});

export async function generateMetadata({
  params,
}: {
  params: { lng: string };
}): Promise<Metadata | undefined> {
  return {
    title: params.lng === "en" ? "Flutter Fleet" : "Flutter Fleet",
    description: params.lng === "en" ? "Flutter Fleet" : "Flutter Fleet.",
    metadataBase: new URL("https://kjxbyz.com"),
    icons: {
      icon: `${basePath}/logo.png`,
    },
  };
}

export async function generateStaticParams() {
  return languages.map((lng: string) => ({ lng }));
}

export default async function RootLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: {
    lng: string;
  };
}) {
  return (
    <html lang={params.lng} dir={dir(params.lng)} suppressHydrationWarning>
      <body className={cx(sfPro.variable, inter.variable)}>
        <NextTopLoader height={1} />
        <Providers>
          {NEXT_PUBLIC_SHOW_PARTICLES && <Particles />}
          <Header lng={params.lng} />
          <main
            id="main"
            className="flex min-h-screen w-full flex-col items-center justify-center py-32"
          >
            {children}
            <GoogleAnalytics />
          </main>
          <Footer lng={params.lng} />
          <CookieBanner lng={params.lng} />
        </Providers>
        <ScrollToTop
          smooth
          component={
            <BiArrowToTop className="mx-auto my-0 h-5 w-5 text-gray-700" />
          }
        />
      </body>
    </html>
  );
}
