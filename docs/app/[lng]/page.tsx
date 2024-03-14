"use client";
import Balancer from "react-wrap-balancer";
import { RoughNotation } from "react-rough-notation";
import { Github } from "@/components/shared/icons";
import { SiAlipay, SiAlibabacloud, SiFlutter } from "react-icons/si";
import { FaBlog, FaWeibo, FaWeixin, FaAws } from "react-icons/fa";
import Link from "next/link";
import Image from "next/image";
import dynamic from "next/dynamic";
import { useTranslation } from "@/i18n/client";
import { basePath } from "@/constants";
import { allPosts } from "contentlayer/generated";

const DynamicCard = dynamic(() => import("@/components/home/card"), {
  ssr: false,
});

export default function Home({
  params,
}: {
  params: {
    lng: string;
  };
}) {
  const { t } = useTranslation(params.lng, "header");
  const post = allPosts
    .filter((post) => post.slug.startsWith(`${params.lng}/blog`))
    .sort((a, b) => {
      return new Date(a.publishedAt) > new Date(b.publishedAt) ? -1 : 1;
    })
    .at(0);
  return (
    <>
      <div className="z-10 w-full max-w-xl px-5 xl:px-0">
        {post && (
          <Link
            href={`/${post.slug}`}
            rel="noreferrer"
            className="mx-auto mb-12 flex max-w-fit animate-fade-up items-center justify-center space-x-2 overflow-hidden rounded-full bg-blue-100 px-7 py-2 transition-colors hover:bg-blue-200"
          >
            <FaBlog className="h-5 w-5 text-[#1d9bf0]" />
            <p className="text-sm font-semibold text-[#1d9bf0]">{post.title}</p>
          </Link>
        )}
        <div className="mb-8 flex items-center justify-center space-x-20">
          <Image
            className="rounded-full"
            alt="logo"
            src={`${basePath}/logo.png`}
            width={160}
            height={160}
          />
        </div>
        <h1
          className="animate-fade-up bg-clip-text text-center font-display text-4xl font-bold tracking-[-0.02em] text-black/80 opacity-0 drop-shadow-sm dark:text-white/80 md:text-7xl md:leading-[5rem]"
          style={{ animationDelay: "0.15s", animationFillMode: "forwards" }}
        >
          <Balancer>{t("title")}</Balancer>
        </h1>
        <p
          className="mt-6 animate-fade-up text-center text-red-400 opacity-0 md:text-xl"
          style={{ animationDelay: "0.25s", animationFillMode: "forwards" }}
        >
          <Balancer>
            <RoughNotation
              animate
              type="highlight"
              show={true}
              color="rgb(36, 54, 110)"
              animationDelay={1000}
              animationDuration={2500}
            >
              Plugins for Flutter.
            </RoughNotation>
          </Balancer>
        </p>
        <div
          className="mx-auto mt-6 flex animate-fade-up items-center justify-center space-x-5 opacity-0"
          style={{ animationDelay: "0.3s", animationFillMode: "forwards" }}
        >
          <a
            className="flex max-w-fit items-center justify-center space-x-2 rounded-full border border-gray-300 bg-white px-5 py-2 text-sm text-gray-600 shadow-md transition-colors hover:border-gray-800 dark:bg-black dark:text-white/80"
            href="https://github.com/FlutterFleet"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Github />
            <p>
              <span className="sm:inline-block">Star on</span> GitHub{" "}
            </p>
          </a>
        </div>
      </div>
      <div className="my-10 grid w-full max-w-screen-xl animate-fade-up grid-cols-1 gap-5 px-5 sm:grid-cols-2 lg:grid-cols-3 xl:px-0">
        {features.map(({ title, description, demo, url, large }) => (
          <DynamicCard
            key={title}
            title={title}
            description={description}
            demo={demo}
            url={url}
            large={large}
          />
        ))}
      </div>
    </>
  );
}

const features = [
  {
    title: "Alipay Flutter",
    description:
      "Alipay for Flutter. ![GitHub tag](https://img.shields.io/github/v/tag/FlutterFleet/alipay_flutter)",
    demo: (
      <SiAlipay className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/alipay-flutter",
    large: false,
  },
  {
    title: "Aliyun OSS",
    description:
      "Aliyun OSS API for Dart. ![Pub Version](https://img.shields.io/pub/v/flutter_aliyun_oss)",
    demo: (
      <SiAlibabacloud className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/aliyun-oss",
    large: false,
  },
  {
    title: "AWS S3",
    description:
      "AWS S3 API for Dart. ![Pub Version](https://img.shields.io/pub/v/minio_flutter)",
    demo: (
      <FaAws className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/minio",
    large: false,
  },
  {
    title: "DxCaptcha Flutter",
    description:
      "Dingxiang Captcha for Flutter. ![Pub Version](https://img.shields.io/pub/v/dxcaptcha_flutter)",
    demo: (
      <SiFlutter className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/dxcaptcha-flutter",
    large: false,
  },
  {
    title: "HCaptcha Flutter",
    description:
      "HCaptcha for Flutter. ![Pub Version](https://img.shields.io/pub/v/hcaptcha_flutter)",
    demo: (
      <SiFlutter className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/hcaptcha-flutter",
  },
  {
    title: "JPush Flutter",
    description:
      "JPush for Flutter. ![Pub Version](https://img.shields.io/pub/v/jpush_flutter2)",
    demo: (
      <SiFlutter className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/jpush-flutter",
  },
  {
    title: "JVerify Flutter",
    description:
      "JVerification for Flutter. ![GitHub tag](https://img.shields.io/github/v/tag/FlutterFleet/jverify_flutter)",
    demo: (
      <SiFlutter className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/jverify-flutter",
    large: false,
  },
  {
    title: "UShare Flutter",
    description:
      "UShare for Flutter. ![GitHub tag](https://img.shields.io/github/v/tag/FlutterFleet/ushare_flutter)",
    demo: (
      <SiFlutter className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/ushare-flutter",
    large: false,
  },
  {
    title: "WeChat Flutter",
    description:
      "WeChat for Flutter. ![GitHub tag](https://img.shields.io/github/v/tag/FlutterFleet/wechat_flutter)",
    demo: (
      <FaWeixin className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/wechat-flutter",
  },
  {
    title: "Weibo Flutter",
    description:
      "Weibo for Flutter. ![GitHub tag](https://img.shields.io/github/v/tag/FlutterFleet/weibo_flutter)",
    demo: (
      <FaWeibo className="h-24 w-24 text-gray-600 transition-all dark:text-white/80" />
    ),
    url: "/docs/weibo-flutter",
  },
];
