# Mahf Firmware CPU Driver

## Universal CPU Performance & Power Management Driver

![Version](https://img.shields.io/badge/version-2.5.1-blue.svg)
![License](https://img.shields.io/badge/license-Proprietary-red.svg)
![Platform](https://img.shields.io/badge/platform-Windows%2011-green.svg)

---

## 📋 İçindekiler

- [Genel Bakış](#genel-bakış)
- [Sistem Gereksinimleri](#sistem-gereksinimleri)
- [Kurulum](#kurulum)
- [Özellikler](#özellikler)
- [Kullanım](#kullanım)
- [Teknik Detaylar](#teknik-detaylar)
- [Sorun Giderme](#sorun-giderme)

---

## 🎯 Genel Bakış

Mahf Firmware CPU Driver, Intel, AMD ve ARM mimarilerini destekleyen bağımsız, evrensel bir CPU performans ve güç yönetim sürücüsüdür. Üretici sürücülerinden tamamen bağımsız çalışır ve gelişmiş kernel-level optimizasyonlar sağlar.

### Neden Mahf CPU Driver?

✅ **Bağımsız Çalışma** - Üretici sürücülerine bağımlılık yok
✅ **Evrensel Destek** - Intel, AMD, ARM, tüm işlemcilerle uyumlu
✅ **Kernel-Level** - Doğrudan donanım erişimi
✅ **Performans Odaklı** - Optimize edilmiş güç ve hız dengesi
✅ **Kullanıcı Dostu** - Kolay kontrol paneli arayüzü

---

## 💻 Sistem Gereksinimleri

### Minimum Gereksinimler

- **İşletim Sistemi:** Windows 10 (Build 22000 veya üzeri) / Windows 11
- **İşlemci:** Herhangi bir x64 veya ARM64 işlemci
- **RAM:** 50 MB boş alan
- **Disk:** 10 MB kurulum alanı
- **Yetki:** Administrator hakları

### Önerilen Sistem

- Windows 11 (22H2 veya üzeri)
- Modern çok çekirdekli işlemci
- UEFI firmware

### Desteklenen İşlemciler

| Üretici | Mimari | Modeller |
|---------|--------|----------|
| Intel | x64 | Core i3/i5/i7/i9, Xeon, Pentium, Celeron |
| AMD | x64 | Ryzen, Threadripper, EPYC, Athlon |
| ARM | ARM64 | Snapdragon, Apple M-series (Windows), MediaTek |

---

## 📦 Kurulum

### Otomatik Kurulum (Önerilen)

1. `MahfCPUSetup_2.5.1.exe` dosyasını çalıştırın
2. **Administrator** olarak çalıştırdığınızdan emin olun
3. Kurulum sihirbazındaki adımları takip edin
4. Kurulum tamamlandığında sistemi yeniden başlatın

### Manuel Kurulum

Administrator olarak komut satırından:

```batch
install.bat
```

### Komponent Kurulumu

Paket şu dosyaları içerir:

```
📦 Mahf CPU Driver Package
├── 📁 Driver/
│   ├── mahf_core.sys        (Kernel driver)
│   ├── mahf_cpu.inf         (Installation info)
│   └── mahf_cpu.cat         (Digital signature)
├── 📁 Bin/
│   ├── mahf_control.dll     (Control library)
│   ├── mahf_service.exe     (Background service)
│   ├── MahfControlPanel.exe (GUI application)
│   └── mahf_uninstall.exe   (Uninstaller)
├── 📁 Resources/
│   └── [Icons and assets]
├── install.bat              (Installation script)
├── uninstall.bat           (Removal script)
├── README.md               (This file)
└── LICENSE.txt             (License agreement)
```

---

## ⚡ Özellikler

### 1. Performans Modları

#### 🛡️ Power Save (Güç Tasarrufu)
- Minimum güç tüketimi
- Düşük sıcaklık
- Laptop kullanımı için ideal
- CPU frekansı: %60 base

#### ⚖️ Balanced (Dengeli)
- Güç ve performans dengesi
- Günlük kullanım için optimal
- Otomatik dinamik ölçekleme
- CPU frekansı: %100 base

#### 🚀 Performance (Performans)
- Yüksek performans
- Oyun ve iş yükleri için
- Turbo boost aktif
- CPU frekansı: %120 base

#### 🔥 Extreme (Aşırı)
- Maksimum performans
- Profesyonel iş yükleri
- Tüm limitler kaldırıldı
- CPU frekansı: Maximum turbo

### 2. Otomatik Optimizasyonlar

- **Multi-threading Optimization** - Thread yönetimi
- **Dynamic Frequency Scaling** - Otomatik frekans ayarı
- **Thermal Management** - Sıcaklık kontrolü
- **Power Efficiency** - Enerji verimliliği
- **Core Parking** - Çekirdek park etme
- **Cache Optimization** - Önbellek optimizasyonu

### 3. Gerçek Zamanlı İzleme

- CPU kullanım yüzdesi
- Çekirdek sıcaklıkları
- Güç tüketimi (Watt)
- Anlık frekans
- Voltaj değerleri
- Thread aktivitesi

---

## 🎮 Kullanım

### Kontrol Paneli

1. **Başlatma**
   ```
   Start Menu > Mahf CPU Control Panel
   ```

2. **Ana Ekran**
   - Sol panel: CPU bilgileri
   - Orta panel: Performans metrikleri
   - Sağ panel: Mod seçimi

3. **Mod Değiştirme**
   - İstediğiniz modu tıklayın
   - Değişiklik anında uygulanır
   - Yeniden başlatma gereksiz

### Komut Satırı

```batch
# Servis durumunu kontrol et
sc query MahfService

# Servisi başlat
sc start MahfService

# Servisi durdur
sc stop MahfService

# Sürücü durumu
sc query MahfCPU
```

### Registry Ayarları

Gelişmiş kullanıcılar için registry düzenlemesi:

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\MahfCPU\Parameters
```

| Key | Type | Açıklama | Varsayılan |
|-----|------|----------|-----------|
| PerformanceMode | DWORD | Performans modu (0-3) | 1 |
| DynamicScaling | DWORD | Otomatik ölçekleme | 1 |
| ThermalThreshold | DWORD | Sıcaklık limiti (°C) | 85 |
| PowerLimit | DWORD | Güç limiti (W) | 65 |
| BoostEnabled | DWORD | Turbo boost | 1 |

---

## 🔧 Teknik Detaylar

### Mimari

```
┌─────────────────────────────────────┐
│   Mahf Control Panel (User-Mode)   │
│         MahfControlPanel.exe        │
└────────────────┬────────────────────┘
                 │ IOCTL
┌────────────────▼────────────────────┐
│    Mahf Service (User-Mode)         │
│        mahf_service.exe             │
└────────────────┬────────────────────┘
                 │ DeviceIoControl
┌────────────────▼────────────────────┐
│  Mahf Driver (Kernel-Mode)          │
│         mahf_core.sys               │
└────────────────┬────────────────────┘
                 │ MSR Read/Write
┌────────────────▼────────────────────┐
│           CPU Hardware              │
│   (Intel / AMD / ARM Processor)     │
└─────────────────────────────────────┘
```

### IOCTL Kodları

```c
#define IOCTL_MAHF_GET_CPU_INFO      0x222000
#define IOCTL_MAHF_SET_PERFORMANCE   0x222004
#define IOCTL_MAHF_GET_PERFORMANCE   0x222008
#define IOCTL_MAHF_SET_FREQUENCY     0x22200C
#define IOCTL_MAHF_GET_TEMPERATURE   0x222010
```

### MSR (Model Specific Register) Kullanımı

Sürücü aşağıdaki MSR'lara erişir:

- `0x198` - IA32_PERF_STATUS (Mevcut performans)
- `0x199` - IA32_PERF_CTL (Performans kontrolü)
- `0x19C` - IA32_THERM_STATUS (Sıcaklık)
- `0x1B1` - IA32_PACKAGE_THERM_STATUS (Paket sıcaklığı)
- `0xCE` - MSR_PLATFORM_INFO (Platform bilgisi)
- `0x1AD` - MSR_TURBO_RATIO_LIMIT (Turbo limitleri)

---

## 🛠️ Sorun Giderme

### Sürücü Yüklenmiyor

**Semptom:** Driver yükleme hatası

**Çözüm:**
1. Administrator hakları ile çalıştırın
2. Secure Boot'u geçici olarak kapatın
3. Test Mode'u etkinleştirin:
   ```batch
   bcdedit /set testsigning on
   ```
4. Sistemi yeniden başlatın

### Kontrol Paneli Bağlanamıyor

**Semptom:** "Driver: Not Connected" hatası

**Çözüm:**
1. Sürücünün yüklü olduğunu kontrol edin:
   ```batch
   sc query MahfCPU
   ```
2. Servisi manuel başlatın:
   ```batch
   sc start MahfCPU
   sc start MahfService
   ```

### Performans Değişmiyor

**Semptom:** Mod değişikliği etkisiz

**Çözüm:**
1. BIOS'ta CPU güç yönetimi ayarlarını kontrol edin
2. Windows güç planını "High Performance" yapın
3. Registry ayarlarını kontrol edin

### Yüksek Sıcaklık

**Semptom:** CPU sıcaklığı yüksek

**Çözüm:**
1. Extreme modundan çıkın
2. Thermal threshold değerini düşürün
3. Soğutma sistemini kontrol edin
4. Power Save moduna geçin

---

## 📄 Lisans

Copyright © 2024 Mahf Corporation. All Rights Reserved.

Bu yazılım özel mülkiyettir. Dağıtım, değiştirme veya ters mühendislik yasaktır.

---

## 📞 Destek

- **Website:** https://www.mahfcorp.com/
- **Email:** support@mahfcorp.com
- **Forum:** https://forum.mahfcorp.com/

---

## 🔄 Sürüm Geçmişi

### v2.5.1 (2024-12-09)
- ARM64 desteği eklendi
- Thermal yönetimi iyileştirildi
- Kontrol paneli UI güncellemesi
- Bug düzeltmeleri

### v2.5.0 (2024-11-15)
- İlk kararlı sürüm
- Intel ve AMD tam desteği
- 4 performans modu
- Gerçek zamanlı izleme

---

**Mahf Corporation** - *Independent. Universal. Optimized.*