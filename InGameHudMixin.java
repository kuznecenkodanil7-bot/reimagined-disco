package ru.nauzer.visuals.config;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import net.fabricmc.loader.api.FabricLoader;
import ru.nauzer.visuals.feature.ModuleRegistry;
import ru.nauzer.visuals.feature.VisualModule;

import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public final class VisualConfig {
    private static final Gson GSON = new GsonBuilder().setPrettyPrinting().create();
    private static final Path CONFIG_PATH = FabricLoader.getInstance().getConfigDir().resolve("nauzer-visuals.json");

    public int accentStart = 0xFFFF7A1D;
    public int accentEnd = 0xFF73390B;
    public int hudX = 8;
    public int hudY = 8;
    public int particleRate = 3;
    public boolean soundEnabled = true;
    public List<String> keywords = new ArrayList<>(List.of("чит", "cheat", "бан", "ban", "raidmine", "nauzer"));

    public void load() {
        if (!Files.exists(CONFIG_PATH)) {
            applyDefaultsFromModules();
            save();
            return;
        }

        try (Reader reader = Files.newBufferedReader(CONFIG_PATH, StandardCharsets.UTF_8)) {
            JsonObject root = GSON.fromJson(reader, JsonObject.class);
            if (root == null) {
                applyDefaultsFromModules();
                save();
                return;
            }

            accentStart = getInt(root, "accentStart", accentStart);
            accentEnd = getInt(root, "accentEnd", accentEnd);
            hudX = getInt(root, "hudX", hudX);
            hudY = getInt(root, "hudY", hudY);
            particleRate = Math.max(0, Math.min(10, getInt(root, "particleRate", particleRate)));
            soundEnabled = !root.has("soundEnabled") || root.get("soundEnabled").getAsBoolean();

            if (root.has("keywords") && root.get("keywords").isJsonArray()) {
                Set<String> unique = new LinkedHashSet<>();
                root.getAsJsonArray("keywords").forEach(element -> {
                    String value = element.getAsString().trim();
                    if (!value.isBlank()) unique.add(value.toLowerCase());
                });
                keywords = new ArrayList<>(unique);
            }

            if (root.has("modules") && root.get("modules").isJsonObject()) {
                JsonObject modules = root.getAsJsonObject("modules");
                for (VisualModule module : ModuleRegistry.all()) {
                    if (modules.has(module.id())) {
                        module.setEnabled(modules.get(module.id()).getAsBoolean());
                    }
                }
            }
        } catch (Exception exception) {
            System.err.println("[Nauzer Visuals] Failed to load config, using defaults: " + exception.getMessage());
            applyDefaultsFromModules();
            save();
        }
    }

    public void save() {
        JsonObject root = new JsonObject();
        root.addProperty("accentStart", accentStart);
        root.addProperty("accentEnd", accentEnd);
        root.addProperty("hudX", hudX);
        root.addProperty("hudY", hudY);
        root.addProperty("particleRate", particleRate);
        root.addProperty("soundEnabled", soundEnabled);
        root.add("keywords", GSON.toJsonTree(keywords));

        JsonObject modules = new JsonObject();
        for (VisualModule module : ModuleRegistry.all()) {
            modules.addProperty(module.id(), module.enabled());
        }
        root.add("modules", modules);

        try {
            Files.createDirectories(CONFIG_PATH.getParent());
            try (Writer writer = Files.newBufferedWriter(CONFIG_PATH, StandardCharsets.UTF_8)) {
                GSON.toJson(root, writer);
            }
        } catch (IOException exception) {
            System.err.println("[Nauzer Visuals] Failed to save config: " + exception.getMessage());
        }
    }

    private void applyDefaultsFromModules() {
        // Modules already contain their own default state. This method exists to make the first config write explicit.
    }

    private int getInt(JsonObject root, String key, int fallback) {
        try {
            return root.has(key) ? root.get(key).getAsInt() : fallback;
        } catch (Exception ignored) {
            return fallback;
        }
    }
}
