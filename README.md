# 基于硅基流动API的学术GPT配置脚本，可使用DeepSeek-R1,DeepSeek-V3等模型

本项目提供了一套基于硅基流动API的[GPT Academic](https://github.com/binary-husky/gpt_academic)配置脚本，旨在简化部署流程。
其中，[samonysh](https://github.com/samonysh)作者在[链接](https://github.com/binary-husky/gpt_academic/pull/2131)提供了硅基流动API集成。

## 使用方法
0. 访问[硅基流动](https://cloud.siliconflow.cn/account/ak)获取API
1. 下载并拉取[更新](https://github.com/samonysh/gpt_academic)：bash download.sh
2. 配置API与模型：bash configure.sh <API_KEY> <MODEL_NAME>
3. 启动服务：bash start.sh

### 支持的模型

请确保你的模型 '<MODEL_NAME>' 在 SiliconFlow 的允许列表中。
截至 2025 年 3 月 3 日，支持的模型"至少"包括：
  - deepseek-ai/DeepSeek-R1
  - Pro/deepseek-ai/DeepSeek-R1
  - deepseek-ai/DeepSeek-V3
  - Pro/deepseek-ai/DeepSeek-V3
*如有更新请以官方文档为准。*

**注意：标注Pro模型需要使用充值金额，无法使用赠送金额！**

更多信息请参考[官方文档](https://docs.siliconflow.cn/cn/api-reference/chat-completions/chat-completions)
