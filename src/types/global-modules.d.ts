/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

declare module "libvesktop" {
    export function getAccentColor(): string | null;
    export function updateUnityLauncherCount(count: number): boolean;
    export function requestBackground(autoStart: boolean, commandLine: string[]): boolean;
}

declare module "discord-types/general" {
    export interface Channel {
        id: string;
        type: number;
        guild_id?: string;
        name?: string;
        topic?: string;
        last_message_id?: string;
        position?: number;
        parent_id?: string;
        nsfw?: boolean;
        rate_limit_per_user?: number;
        recipients?: any[];
        icon?: string;
        owner_id?: string;
        application_id?: string;
        managed?: boolean;
        bitrate?: number;
        user_limit?: number;
    }

    export interface Message {
        id: string;
        type: number;
        content: string;
        channel_id: string;
        author: any;
        attachments: any[];
        embeds: any[];
        mentions: any[];
        mention_roles: any[];
        pinned: boolean;
        mention_everyone: boolean;
        tts: boolean;
        timestamp: string;
        edited_timestamp: string | null;
        flags: number;
        components: any[];
        nonce?: string | number;
        webhook_id?: string;
        message_reference?: any;
        referenced_message?: any;
        interaction?: any;
        thread?: any;
        sticker_items?: any[];
        position?: number;
    }

    export interface User {
        id: string;
        username: string;
        discriminator: string;
        avatar?: string;
        bot?: boolean;
        system?: boolean;
        mfa_enabled?: boolean;
        banner?: string;
        accent_color?: number;
        locale?: string;
        verified?: boolean;
        email?: string;
        flags?: number;
        premium_type?: number;
        public_flags?: number;
    }

    export interface Guild {
        id: string;
        name: string;
        icon?: string;
        splash?: string;
        banner?: string;
        owner_id: string;
        region?: string;
        afk_channel_id?: string;
        afk_timeout?: number;
        verification_level?: number;
        default_message_notifications?: number;
        explicit_content_filter?: number;
        roles: any[];
        emojis: any[];
        features: string[];
        mfa_level?: number;
        application_id?: string;
        system_channel_id?: string;
        system_channel_flags?: number;
        rules_channel_id?: string;
        max_presences?: number;
        max_members?: number;
        vanity_url_code?: string;
        description?: string;
        banner_hash?: string;
        premium_tier?: number;
        premium_subscription_count?: number;
        preferred_locale?: string;
        public_updates_channel_id?: string;
        max_video_channel_users?: number;
        approximate_member_count?: number;
        approximate_presence_count?: number;
    }
}

declare module "@plugins/devCompanion.dev/initWs" {
    export function initWs(): void;
}
