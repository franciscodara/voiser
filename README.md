# FinWise

Um aplicativo financeiro completo construído com Flutter. 

## 🚀 Pré-requisitos (Comum a todos os SOs)

Antes de começar, certifique-se de ter instalado em sua máquina:
- [Git](https://git-scm.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão mais recente recomendada)
- Editor de código de sua preferência (recomendamos [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio))

Para verificar se o seu ambiente está corretamente configurado, rode o comando abaixo no terminal:
```bash
flutter doctor
```
Certifique-se de resolver quaisquer "issues" que o `flutter doctor` relatar antes de prosseguir.

---

## 🍎 Executando no MacOS

Para compilar e executar o projeto no macOS (focado em iOS ou macOS desktop), siga estes passos:

### 1. Preparando o ambiente
- Instale o decodificador **Xcode** através da Mac App Store.
- Após instalar, abra o Xcode uma vez para aceitar os termos de licença e instalar os componentes adicionais do simulador, ou rode pelo terminal:
  ```bash
  sudo xcodebuild -license
  ```
- Instale e atualize as ferramentas de gerenciamento de dependências nativas (CocoaPods) essenciais para pacotes iOS:
  ```bash
  sudo gem install cocoapods
  ```

### 2. Rodando o app
1. Clone este repositório e acesse o diretório principal:
   ```bash
   git clone <sua-url-do-repositorio>
   cd finwise
   ```
2. Baixe todas as dependências do Dart/Flutter:
   ```bash
   flutter pub get
   ```
3. Abra o aplicativo **Simulator** (pode ser encontrado pelo Spotlight) ou conecte um iPhone físico à sua máquina (com "Modo de Desenvolvedor" ativado).
4. Inicialize a aplicação:
   ```bash
   flutter run
   ```

---

## 🪟 Executando no Windows

Para compilar e executar o aplicativo no Windows (focado em Android ou Windows desktop):

### 1. Preparando o ambiente
- Baixe e instale o **Android Studio**. Durante a instalação, garanta que os seguintes componentes estão marcados: **Android SDK**, **Android SDK Command-line Tools** e **Android SDK Build-Tools**.
- Você precisa aceitar as licenças padrões do Android SDK para compilar o app:
  ```bash
  flutter doctor --android-licenses
  ```
- *(Opcional)* Para builds nativas de Desktop do Windows, é necessário ter o **Visual Studio 2022** instalado com a carga de trabalho de "Desenvolvimento para Desktop com C++".

### 2. Rodando o app
1. Abra o **Prompt de Comando** ou **PowerShell**, clone o projeto e entre na pasta:
   ```bash
   git clone <sua-url-do-repositorio>
   cd finwise
   ```
2. Sincronize os pacotes do projeto:
   ```bash
   flutter pub get
   ```
3. Abra o **Android Studio** e, via "Device Manager" (Gerenciador de Dispositivos), inicie um Emulador Android. Se preferir, conecte seu aparelho Android via USB com a opção de "Depuração USB" ativada nas configurações de desenvolvedor.
4. Inicie o app:
   ```bash
   flutter run
   ```

---

## 🐧 Executando no Linux

Para desenvolver e rodar o app no Linux (focado no emulador Android ou aplicação Linux nativa):

### 1. Preparando o ambiente
- O Flutter para Linux desktop necessita de alguns binários padrões de compilação. Em distribuições baseadas em Debian/Ubuntu, rode:
  ```bash
  sudo apt-get update
  sudo apt-get install clang cmake git ninja-build pkg-config libgtk-3-dev liblzma-dev unzip
  ```
- Se seu foco for emular no Android, você precisará instalar o **Android Studio** (disponível via Snap ou tarball). Depois, execute as aceitações de licença assim como no Windows:
  ```bash
  flutter doctor --android-licenses
  ```

### 2. Rodando o app
1. Vá para o terminal desejado, clone o projeto e acesse o diretório:
   ```bash
   git clone <sua-url-do-repositorio>
   cd finwise
   ```
2. Puxe as dependências do `pubspec.yaml`:
   ```bash
   flutter pub get
   ```
3. Certifique-se de que o seu dispositivo de destino (Desktop Nativo Linux, Emulador, ou dispositivo móvel conectado) esteja rodando.
4. Execute o app apontando para a engine do Flutter:
   ```bash
   flutter run
   ```

---

## 📦 Visão Geral da Arquitetura

O FinWise utiliza uma abordagem modular baseada em "Features" para garantir escalabilidade e manutenção simples. 

- `lib/core/` - Utilitários globais, temas da aplicação, rotas, componentes reutilizáveis e abstrações principais.
- `lib/features/` - Cada domínio/funcionalidade do app fica isolado na sua pasta. (ex: `expenses`, com seu controle local via Hive e remoto via Supabase).

Para debugar a camada do Supabase ou o DataSource do Hive, confira `lib/features/expenses/data/datasources/`.
