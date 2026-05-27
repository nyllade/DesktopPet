using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Threading;

namespace DesktopPet.Windows;

public partial class MainWindow : Window
{
    private readonly DispatcherTimer _timer = new() { Interval = TimeSpan.FromMilliseconds(16) };
    private readonly Random _random = new();
    private readonly List<Particle> _particles = new();
    private readonly Dictionary<string, Character> _characters;
    private readonly string _settingsPath;

    private PetSettings _settings = new();
    private string _mode = "companion";
    private string _mood = "calm";
    private string _thought = "";
    private double _tick;
    private double _actionPulse;
    private double _shakePulse;
    private double _spinPulse;
    private double _spinDirection = 1;
    private double _thoughtAlpha;
    private double _nextAutonomy = 140;

    private bool _dragging;
    private bool _hasDragAngle;
    private bool _hasPetAngle;
    private Point _dragStartScreen;
    private Point _dragGestureOriginScreen;
    private Point _lastDragScreen;
    private Point _clickStartWindow;
    private Point _lastMouseWindow;
    private double _lastDragAngle;
    private double _dragAngleTotal;
    private double _lastPetAngle;
    private double _petAngleTotal;
    private DateTime _petMotionStartedAt = DateTime.MinValue;
    private DateTime _petCooldownUntil = DateTime.MinValue;

    public MainWindow()
    {
        InitializeComponent();

        _characters = BuildCharacters();
        _settingsPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "DesktopPet",
            "settings.json");

        LoadSettings();
        ApplyCharacter();
        ApplyWindowPosition();

        _timer.Tick += (_, _) => Animate();
        _timer.Start();
    }

    private static Dictionary<string, Character> BuildCharacters() => new()
    {
        ["nebulaNix"] = new("nebulaNix", "Nebula Nix", "mischievous stargazer", "#FFF070", "#B484FF", new()
        {
            ["click"] = new[] { "orbit check", "cursor gravity", "star blink" },
            ["double"] = new[] { "gravity cancelled", "tiny comet jump", "starburst protocol" },
            ["pet"] = new[] { "purrs in starlight", "orbit warmed", "soft cosmic static" },
            ["study"] = new[] { "quiet orbit engaged", "focus field steady" },
            ["dnd"] = new[] { "silent orbit set", "going dark-soft" },
            ["flick"] = new[] { "whoosh through space", "tiny gravity ride" },
            ["companion"] = new[] { "back in your orbit", "stars back online" }
        }),
        ["pippaOrbitpaw"] = new("pippaOrbitpaw", "Pippa Orbitpaw", "alien scout", "#41AFEB", "#FF97C3", new()
        {
            ["click"] = new[] { "scan complete", "hi hi signal", "curiosity ping" },
            ["double"] = new[] { "boing trajectory", "launch test success", "zap-hop" },
            ["pet"] = new[] { "happy scanner beep", "spots are glowing" },
            ["study"] = new[] { "research mode beep", "scanning focus field" },
            ["dnd"] = new[] { "stealth scout mode", "signal tucked away" },
            ["flick"] = new[] { "rocket paws!", "trajectory accepted" },
            ["companion"] = new[] { "mission resumed", "scout mode on" }
        }),
        ["lumaMoppet"] = new("lumaMoppet", "Luma Moppet", "dramatic snack ghost", "#E054B1", "#6AE4D6", new()
        {
            ["click"] = new[] { "an audience!", "spotlight, please", "tiny gasp" },
            ["double"] = new[] { "dramatic little leap", "encore sparkle" },
            ["pet"] = new[] { "applause accepted", "heart confetti" },
            ["study"] = new[] { "curtain falls quiet", "study scene begins" },
            ["dnd"] = new[] { "intermission hush", "backstage silence" },
            ["flick"] = new[] { "dramatic exit!", "stage spin!" },
            ["companion"] = new[] { "the show resumes", "curtain up" }
        }),
        ["ossiaNocturne"] = new("ossiaNocturne", "Ossia Nocturne", "gothic desk guardian", "#5CB7FF", "#101822", new()
        {
            ["click"] = new[] { "I am watching", "quietly here", "blue flame steady" },
            ["double"] = new[] { "shadow hop", "moonbone flicker" },
            ["pet"] = new[] { "guard softened", "moonlit purr" },
            ["study"] = new[] { "warding distractions", "blue aura steady" },
            ["dnd"] = new[] { "silent ward set", "no noise passes" },
            ["flick"] = new[] { "shadow sweep", "cloak flutter" },
            ["companion"] = new[] { "watch resumed", "guardian awake" }
        }),
        ["velvetHowl"] = new("velvetHowl", "Velvet Howl", "heart-powered puppy", "#FF7AB5", "#A1A0EE", new()
        {
            ["click"] = new[] { "you came!", "tail-heart wag", "best cursor" },
            ["double"] = new[] { "heart hop!", "zoomie sparkle" },
            ["pet"] = new[] { "happy heart storm", "more please" },
            ["study"] = new[] { "quiet puppy promise", "focus cuddle nearby" },
            ["dnd"] = new[] { "quiet paws", "softly staying" },
            ["flick"] = new[] { "zoomie launch!", "wheee paws" },
            ["companion"] = new[] { "right beside you", "heart mode on" }
        }),
        ["mochiCloudlet"] = new("mochiCloudlet", "Mochi Cloudlet", "soft cloud familiar", "#FF9DD3", "#8BD0F6", new()
        {
            ["click"] = new[] { "soft hello", "cloudlet peeks", "tiny warm puff" },
            ["double"] = new[] { "cotton hop", "soft bounce" },
            ["pet"] = new[] { "cloud purr", "softer now" },
            ["study"] = new[] { "quiet cloud nearby", "soft focus drift" },
            ["dnd"] = new[] { "small hush cloud", "quiet wool mode" },
            ["flick"] = new[] { "cloud puff!", "soft tumble" },
            ["companion"] = new[] { "gentle desk weather", "cloudlet awake" }
        })
    };

    private Character CurrentCharacter => _characters.GetValueOrDefault(_settings.CharacterId) ?? _characters["nebulaNix"];

    private void Animate()
    {
        _tick += 1.0 / 60.0;
        _actionPulse = Math.Max(0, _actionPulse - 0.024);
        _shakePulse = Math.Max(0, _shakePulse - 0.038);
        _spinPulse = Math.Max(0, _spinPulse - 0.022);
        _thoughtAlpha = Math.Max(0, _thoughtAlpha - 0.006);
        _nextAutonomy -= 1.0 / 60.0;

        if (_nextAutonomy <= 0 && _mode == "companion" && !_dragging)
        {
            _nextAutonomy = RandomRange(120, 300);
            _mood = _random.NextDouble() > 0.45 ? "playful" : "curious";
            _actionPulse = _mood == "playful" ? 0.75 : 0.35;
            Burst("sparkle", _mood == "playful" ? 5 : 2);
        }

        UpdateParticles();
        DrawPose();
        DrawThought();
    }

    private void DrawPose()
    {
        var breath = Math.Sin(_tick * (_mode == "study" ? 1.2 : 1.7));
        var rotation = 0.0;
        var y = breath * 3.0;
        var sx = _settings.Size;
        var sy = _settings.Size;

        if (_mood == "curious")
        {
            var centerX = Canvas.GetLeft(PetImage) + PetImage.Width / 2;
            rotation += Clamp((_lastMouseWindow.X - centerX) / 120.0, -1, 1) * 4.0;
        }
        else if (_mood == "playful")
        {
            rotation += Math.Sin(_tick * 8.0) * 7.0;
        }

        if (_actionPulse > 0 && _mood == "playful")
        {
            y += Math.Sin((1 - _actionPulse) * Math.PI) * 34.0;
            sx += _actionPulse * 0.04;
            sy -= _actionPulse * 0.03;
        }

        if (_shakePulse > 0.01)
        {
            rotation += Math.Sin(_tick * 34.0) * _shakePulse * 10.5;
            y += Math.Cos(_tick * 42.0) * _shakePulse * 4.2;
            sx += _shakePulse * 0.035;
            sy -= _shakePulse * 0.026;
        }

        if (_spinPulse > 0.01)
        {
            var progress = 1.0 - _spinPulse;
            var eased = 1.0 - Math.Pow(1.0 - progress, 3.0);
            rotation += _spinDirection * eased * 360.0;
            y += Math.Sin(progress * Math.PI) * 8.0;
        }

        PetScaleTransform.ScaleX = sx;
        PetScaleTransform.ScaleY = sy;
        PetRotateTransform.Angle = rotation;
        PetTranslateTransform.Y = y;
        Shadow.Opacity = _mode == "dnd" ? 0.08 : 0.18;
    }

    private void Pet_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
    {
        _clickStartWindow = e.GetPosition(this);
        _dragStartScreen = PointToScreen(_clickStartWindow);
        _dragGestureOriginScreen = _dragStartScreen;
        _lastDragScreen = _dragStartScreen;
        _hasDragAngle = false;
        _dragAngleTotal = 0;
        _dragging = true;
        _mood = "curious";
        PetImage.CaptureMouse();
    }

    private void Pet_MouseMove(object sender, MouseEventArgs e)
    {
        _lastMouseWindow = e.GetPosition(this);

        if (_dragging && e.LeftButton == MouseButtonState.Pressed)
        {
            var current = PointToScreen(_lastMouseWindow);
            var step = current - _lastDragScreen;
            var stepDistance = step.Length;
            if (stepDistance > 8)
            {
                var gain = Clamp((stepDistance - 8) / 42.0, 0.16, 1.35);
                _shakePulse = Clamp(Math.Max(_shakePulse, gain) + stepDistance / 260.0 * _settings.MotionIntensity, 0, 1.55 * _settings.MotionIntensity);
            }

            UpdateDragSpin(current);
            Left = Clamp(Left + step.X, 0, SystemParameters.VirtualScreenWidth - Width);
            Top = Clamp(Top + step.Y, 0, SystemParameters.VirtualScreenHeight - Height);
            _lastDragScreen = current;
            return;
        }

        TrackCursorPetting(_lastMouseWindow);
    }

    private void Pet_MouseLeftButtonUp(object sender, MouseButtonEventArgs e)
    {
        PetImage.ReleaseMouseCapture();
        var moved = (e.GetPosition(this) - _clickStartWindow).Length;
        _dragging = false;

        if (moved > 8)
        {
            _actionPulse = 0.9;
            Burst("dust", 6);
            if (_shakePulse > 1.1 || _spinPulse > 0.3) ShowThought(Voice("flick"));
            SaveSettings();
            return;
        }

        if (e.ClickCount >= 2)
        {
            _mood = "playful";
            _actionPulse = 1.0;
            Burst("star", 10);
            ShowThought(Voice("double"));
        }
        else
        {
            _mood = "curious";
            _actionPulse = 0.32;
            ShowThought(Voice("click"));
        }
    }

    private void UpdateDragSpin(Point screenPoint)
    {
        var dx = screenPoint.X - _dragGestureOriginScreen.X;
        var dy = screenPoint.Y - _dragGestureOriginScreen.Y;
        if (Math.Sqrt(dx * dx + dy * dy) < 42) return;

        var angle = Math.Atan2(dy, dx);
        if (!_hasDragAngle)
        {
            _hasDragAngle = true;
            _lastDragAngle = angle;
            return;
        }

        var delta = NormalizeAngle(angle - _lastDragAngle);
        _dragAngleTotal += delta;
        _lastDragAngle = angle;
        if (Math.Abs(_dragAngleTotal) > Math.PI * 1.45)
        {
            _spinPulse = 1;
            _spinDirection = _dragAngleTotal >= 0 ? 1 : -1;
            _shakePulse = 1.55 * _settings.MotionIntensity;
            _dragAngleTotal = 0;
            _hasDragAngle = false;
        }
    }

    private void TrackCursorPetting(Point point)
    {
        if (_mode == "dnd" || DateTime.Now < _petCooldownUntil) return;
        var center = new Point(Canvas.GetLeft(PetImage) + PetImage.Width / 2, Canvas.GetTop(PetImage) + PetImage.Height / 2);
        var dx = point.X - center.X;
        var dy = point.Y - center.Y;
        if (Math.Sqrt(dx * dx + dy * dy) < 24) return;

        var angle = Math.Atan2(dy, dx);
        if (!_hasPetAngle || DateTime.Now - _petMotionStartedAt > TimeSpan.FromSeconds(2.4))
        {
            _hasPetAngle = true;
            _lastPetAngle = angle;
            _petAngleTotal = 0;
            _petMotionStartedAt = DateTime.Now;
            return;
        }

        _petAngleTotal += NormalizeAngle(angle - _lastPetAngle);
        _lastPetAngle = angle;
        if (Math.Abs(_petAngleTotal) > Math.PI * 1.65)
        {
            _petAngleTotal = 0;
            _hasPetAngle = false;
            _petCooldownUntil = DateTime.Now.AddSeconds(1.2);
            _actionPulse = 0.55;
            Burst("heart", 9);
            ShowThought(Voice("pet"));
        }
    }

    private void Pet_MouseRightButtonUp(object sender, MouseButtonEventArgs e)
    {
        var menu = new ContextMenu();

        var header = new MenuItem { Header = $"{CurrentCharacter.Name} - {CurrentCharacter.Subtitle}", IsEnabled = false };
        menu.Items.Add(header);
        menu.Items.Add(new Separator());

        var characterMenu = new MenuItem { Header = "Character" };
        foreach (var character in _characters.Values)
        {
            var item = new MenuItem { Header = character.Name, IsCheckable = true, IsChecked = character.Id == _settings.CharacterId };
            item.Click += (_, _) =>
            {
                _settings.CharacterId = character.Id;
                ApplyCharacter();
                Burst("star", 8);
                ShowThought($"{character.Name} arrived");
                SaveSettings();
            };
            characterMenu.Items.Add(item);
        }
        menu.Items.Add(characterMenu);

        var modeMenu = new MenuItem { Header = "Mode" };
        foreach (var mode in new[] { ("Companion", "companion"), ("Study Focus", "study"), ("Do Not Disturb", "dnd") })
        {
            var item = new MenuItem { Header = mode.Item1, IsCheckable = true, IsChecked = _mode == mode.Item2 };
            item.Click += (_, _) =>
            {
                _mode = mode.Item2;
                ShowThought(_mode == "dnd" ? Voice("dnd") : Voice(_mode == "study" ? "study" : "companion"));
                SaveSettings();
            };
            modeMenu.Items.Add(item);
        }
        menu.Items.Add(modeMenu);

        var sizeMenu = new MenuItem { Header = "Size" };
        foreach (var size in new[] { ("Micro", 0.42), ("Tiny", 0.55), ("Small", 0.68), ("Medium", 0.82), ("Large", 1.0) })
        {
            var item = new MenuItem { Header = size.Item1, IsCheckable = true, IsChecked = Math.Abs(_settings.Size - size.Item2) < 0.04 };
            item.Click += (_, _) => { _settings.Size = size.Item2; SaveSettings(); };
            sizeMenu.Items.Add(item);
        }
        menu.Items.Add(sizeMenu);

        var motionMenu = new MenuItem { Header = "Motion" };
        foreach (var motion in new[] { ("Gentle", 0.65), ("Normal", 1.0), ("Bouncy", 1.45) })
        {
            var item = new MenuItem { Header = motion.Item1, IsCheckable = true, IsChecked = Math.Abs(_settings.MotionIntensity - motion.Item2) < 0.04 };
            item.Click += (_, _) => { _settings.MotionIntensity = motion.Item2; SaveSettings(); };
            motionMenu.Items.Add(item);
        }
        menu.Items.Add(motionMenu);

        menu.Items.Add(new Separator());
        menu.Items.Add(new MenuItem { Header = "Reset Position", Command = new RelayCommand(() => { Left = SystemParameters.WorkArea.Right - Width - 80; Top = SystemParameters.WorkArea.Bottom - Height - 80; SaveSettings(); }) });
        menu.Items.Add(new MenuItem { Header = "Quit", Command = new RelayCommand(Close) });

        menu.IsOpen = true;
    }

    private void ApplyCharacter()
    {
        var uri = new Uri($"pack://application:,,,/Assets/{CurrentCharacter.Id}.png", UriKind.Absolute);
        PetImage.Source = new BitmapImage(uri);
        Bubble.BorderBrush = BrushFromHex(CurrentCharacter.Accent);
    }

    private void ShowThought(string text)
    {
        if (_mode == "dnd") return;
        _thought = text;
        _thoughtAlpha = 1;
        BubbleText.Text = text;
        Bubble.Visibility = Visibility.Visible;
        Bubble.Measure(new Size(280, 32));
        Canvas.SetLeft(Bubble, Clamp(180 - Bubble.DesiredSize.Width / 2, 10, 350 - Bubble.DesiredSize.Width));
    }

    private void DrawThought()
    {
        Bubble.Opacity = _thoughtAlpha;
        if (_thoughtAlpha <= 0.03 || string.IsNullOrWhiteSpace(_thought)) Bubble.Visibility = Visibility.Collapsed;
    }

    private void Burst(string type, int count)
    {
        var color = type == "heart" ? "#FF7AB5" : CurrentCharacter.Accent;
        for (var i = 0; i < count; i++)
        {
            var text = new TextBlock
            {
                Text = type == "heart" ? "♡" : type == "dust" ? "•" : "✦",
                FontSize = type == "heart" ? 18 : 15,
                FontWeight = FontWeights.Bold,
                Foreground = BrushFromHex(color),
                IsHitTestVisible = false
            };
            var particle = new Particle(text, 180 + RandomRange(-58, 58), 220 + RandomRange(-34, 80), RandomRange(-0.5, 0.5), RandomRange(-1.3, -0.45));
            _particles.Add(particle);
            ParticleLayer.Children.Add(text);
        }
    }

    private void UpdateParticles()
    {
        for (var i = _particles.Count - 1; i >= 0; i--)
        {
            var p = _particles[i];
            p.X += p.Dx;
            p.Y += p.Dy;
            p.Life -= 0.018;
            p.Text.Opacity = p.Life;
            Canvas.SetLeft(p.Text, p.X);
            Canvas.SetTop(p.Text, p.Y);
            if (p.Life <= 0)
            {
                ParticleLayer.Children.Remove(p.Text);
                _particles.RemoveAt(i);
            }
        }
    }

    private string Voice(string key)
    {
        var lines = CurrentCharacter.Lines.GetValueOrDefault(key) ?? CurrentCharacter.Lines["click"];
        return lines[_random.Next(lines.Length)];
    }

    private void ApplyWindowPosition()
    {
        Left = double.IsNaN(_settings.Left) ? SystemParameters.WorkArea.Right - Width - 80 : _settings.Left;
        Top = double.IsNaN(_settings.Top) ? SystemParameters.WorkArea.Bottom - Height - 80 : _settings.Top;
    }

    private void LoadSettings()
    {
        try
        {
            if (File.Exists(_settingsPath))
            {
                _settings = JsonSerializer.Deserialize<PetSettings>(File.ReadAllText(_settingsPath)) ?? new PetSettings();
            }
        }
        catch
        {
            _settings = new PetSettings();
        }

        if (!_characters.ContainsKey(_settings.CharacterId)) _settings.CharacterId = "nebulaNix";
        _settings.Size = Clamp(_settings.Size, 0.42, 1.0);
        _settings.MotionIntensity = Clamp(_settings.MotionIntensity, 0.5, 1.6);
    }

    private void SaveSettings()
    {
        _settings.Left = Left;
        _settings.Top = Top;
        Directory.CreateDirectory(Path.GetDirectoryName(_settingsPath)!);
        File.WriteAllText(_settingsPath, JsonSerializer.Serialize(_settings, new JsonSerializerOptions { WriteIndented = true }));
    }

    protected override void OnClosed(EventArgs e)
    {
        SaveSettings();
        base.OnClosed(e);
    }

    private double RandomRange(double min, double max) => min + _random.NextDouble() * (max - min);
    private static double Clamp(double value, double min, double max) => Math.Max(min, Math.Min(max, value));
    private static double NormalizeAngle(double value)
    {
        while (value > Math.PI) value -= Math.PI * 2;
        while (value < -Math.PI) value += Math.PI * 2;
        return value;
    }

    private static Brush BrushFromHex(string hex) => (Brush)new BrushConverter().ConvertFromString(hex)!;
}

public sealed record Character(string Id, string Name, string Subtitle, string Accent, string Secondary, Dictionary<string, string[]> Lines);

public sealed class PetSettings
{
    public string CharacterId { get; set; } = "nebulaNix";
    public double Size { get; set; } = 0.55;
    public double MotionIntensity { get; set; } = 1.0;
    public double Left { get; set; } = double.NaN;
    public double Top { get; set; } = double.NaN;
}

public sealed class Particle
{
    public Particle(TextBlock text, double x, double y, double dx, double dy)
    {
        Text = text;
        X = x;
        Y = y;
        Dx = dx;
        Dy = dy;
    }

    public TextBlock Text { get; }
    public double X { get; set; }
    public double Y { get; set; }
    public double Dx { get; }
    public double Dy { get; }
    public double Life { get; set; } = 1.0;
}

public sealed class RelayCommand : System.Windows.Input.ICommand
{
    private readonly Action _action;

    public RelayCommand(Action action) => _action = action;
    public event EventHandler? CanExecuteChanged;
    public bool CanExecute(object? parameter) => true;
    public void Execute(object? parameter) => _action();
}
