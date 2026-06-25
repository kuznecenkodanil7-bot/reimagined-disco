package ru.nauzer.visuals.screen;

import net.minecraft.client.MinecraftClient;
import net.minecraft.client.gui.DrawContext;
import net.minecraft.client.gui.screen.Screen;
import net.minecraft.client.gui.widget.ButtonWidget;
import net.minecraft.text.Text;
import ru.nauzer.visuals.NauzerVisualsClient;
import ru.nauzer.visuals.feature.Category;
import ru.nauzer.visuals.feature.ModuleRegistry;
import ru.nauzer.visuals.feature.VisualModule;
import ru.nauzer.visuals.util.ColorUtil;

import java.util.List;

public final class VisualScreen extends Screen {
    private final Category selected;

    public VisualScreen() {
        this(Category.HUD);
    }

    private VisualScreen(Category selected) {
        super(Text.literal("Nauzer Visuals"));
        this.selected = selected;
    }

    @Override
    protected void init() {
        int panelX = this.width / 2 - 210;
        int panelY = this.height / 2 - 120;
        int categoryX = panelX + 14;
        int y = panelY + 42;

        for (Category category : Category.values()) {
            Category captured = category;
            String prefix = selected == category ? "▶ " : "  ";
            this.addDrawableChild(ButtonWidget.builder(Text.literal(prefix + category.title()), button -> {
                MinecraftClient.getInstance().setScreen(new VisualScreen(captured));
            }).dimensions(categoryX, y, 118, 20).build());
            y += 24;
        }

        int moduleX = panelX + 148;
        int moduleY = panelY + 42;
        List<VisualModule> modules = ModuleRegistry.byCategory(selected);
        for (VisualModule module : modules) {
            this.addDrawableChild(ButtonWidget.builder(Text.literal(label(module)), button -> {
                module.toggle();
                NauzerVisualsClient.CONFIG.save();
                NauzerVisualsClient.addNotification(module.name(), module.enabled() ? "Включено" : "Выключено");
                MinecraftClient.getInstance().setScreen(new VisualScreen(selected));
            }).dimensions(moduleX, moduleY, 250, 20).build());
            moduleY += 24;
        }

        int bottomY = panelY + 202;
        this.addDrawableChild(ButtonWidget.builder(Text.literal("Частицы -"), button -> {
            NauzerVisualsClient.CONFIG.particleRate = Math.max(0, NauzerVisualsClient.CONFIG.particleRate - 1);
            NauzerVisualsClient.CONFIG.save();
            MinecraftClient.getInstance().setScreen(new VisualScreen(selected));
        }).dimensions(panelX + 148, bottomY, 78, 20).build());

        this.addDrawableChild(ButtonWidget.builder(Text.literal("Частицы: " + NauzerVisualsClient.CONFIG.particleRate), button -> {
        }).dimensions(panelX + 232, bottomY, 82, 20).build());

        this.addDrawableChild(ButtonWidget.builder(Text.literal("Частицы +"), button -> {
            NauzerVisualsClient.CONFIG.particleRate = Math.min(10, NauzerVisualsClient.CONFIG.particleRate + 1);
            NauzerVisualsClient.CONFIG.save();
            MinecraftClient.getInstance().setScreen(new VisualScreen(selected));
        }).dimensions(panelX + 320, bottomY, 78, 20).build());

        this.addDrawableChild(ButtonWidget.builder(Text.literal("Закрыть"), button -> this.close()).dimensions(panelX + 326, panelY + 12, 72, 20).build());
    }

    @Override
    public void render(DrawContext context, int mouseX, int mouseY, float delta) {
        long now = System.currentTimeMillis();
        int panelX = this.width / 2 - 210;
        int panelY = this.height / 2 - 120;
        int panelW = 420;
        int panelH = 240;
        int accent = ColorUtil.pulse(NauzerVisualsClient.CONFIG.accentStart, NauzerVisualsClient.CONFIG.accentEnd, now, 450.0f);

        context.fill(0, 0, this.width, this.height, 0xCC050505);
        drawScreenParticles(context, now);

        context.fill(panelX, panelY, panelX + panelW, panelY + panelH, 0xDD101010);
        context.fill(panelX, panelY, panelX + panelW, panelY + 2, ColorUtil.withAlpha(accent, 210));
        context.fill(panelX, panelY, panelX + 3, panelY + panelH, ColorUtil.withAlpha(accent, 210));
        context.fill(panelX, panelY + 34, panelX + panelW, panelY + 35, 0x33FFFFFF);

        context.drawText(this.textRenderer, "Nauzer Visuals", panelX + 14, panelY + 12, 0xFFFFFFFF, true);
        context.drawText(this.textRenderer, "визуальные эффекты · Fabric 1.21.11", panelX + 116, panelY + 12, 0xFFB8B8B8, true);
        context.drawText(this.textRenderer, "Категории", panelX + 14, panelY + 32, 0xFFB8B8B8, true);
        context.drawText(this.textRenderer, selected.title(), panelX + 148, panelY + 32, accent, true);

        int descY = panelY + 44;
        for (VisualModule module : ModuleRegistry.byCategory(selected)) {
            String desc = crop(module.description(), 43);
            int x = panelX + 405 - this.textRenderer.getWidth(desc);
            context.drawText(this.textRenderer, desc, x, descY + 6, 0xFF838383, false);
            descY += 24;
        }

        context.drawText(this.textRenderer, "RSHIFT — открыть меню  |  H — включить/выключить HUD", panelX + 14, panelY + 220, 0xFF777777, true);
        super.render(context, mouseX, mouseY, delta);
    }

    private void drawScreenParticles(DrawContext context, long now) {
        if (!ModuleRegistry.enabled("screen_particles")) return;
        int count = 36;
        int accentA = ColorUtil.withAlpha(NauzerVisualsClient.CONFIG.accentStart, 75);
        int accentB = ColorUtil.withAlpha(NauzerVisualsClient.CONFIG.accentEnd, 75);
        for (int i = 0; i < count; i++) {
            float t = (now / 1000.0f) + i * 14.31f;
            int x = (int) ((Math.sin(t * 0.31f) * 0.5f + 0.5f) * this.width);
            int y = (int) ((Math.cos(t * 0.23f) * 0.5f + 0.5f) * this.height);
            int color = i % 2 == 0 ? accentA : accentB;
            context.fill(x, y, x + 2, y + 2, color);
        }
    }

    private String label(VisualModule module) {
        return (module.enabled() ? "§aON §7│ §f" : "§cOFF §7│ §f") + module.name();
    }

    private String crop(String text, int max) {
        if (text.length() <= max) return text;
        return text.substring(0, max - 3) + "...";
    }
}
