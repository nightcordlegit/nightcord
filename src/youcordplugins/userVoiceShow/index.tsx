/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import "./style.css";

import { definePluginSettings } from "@api/Settings";
import { Devs, EquicordDevs } from "@utils/constants";
import definePlugin, { OptionType } from "@utils/types";

import { VoiceChannelIndicator } from "./components";

const settings = definePluginSettings({
    showInUserProfileModal: {
        type: OptionType.BOOLEAN,
        description: "Show a user's Voice Channel indicator in their profile next to the name",
        default: true,
        restartNeeded: true
    },
    showInMemberList: {
        type: OptionType.BOOLEAN,
        description: "Show a user's Voice Channel indicator in the member and DMs list",
        default: true,
        restartNeeded: true
    },
    showInMessages: {
        type: OptionType.BOOLEAN,
        description: "Show a user's Voice Channel indicator in messages",
        default: true,
        restartNeeded: true
    }
});

export default definePlugin({
    name: "UserVoiceShow",
    enabledByDefault: true,
    description: "Shows an indicator when a user is in a Voice Channel",
    authors: [Devs.Nuckyz, Devs.LordElias, EquicordDevs.omaw],
    settings,
    renderNicknameIcon({ userId }) {
        if (!settings.store.showInUserProfileModal) return null;
        return (
            <VoiceChannelIndicator userId={userId} isProfile />
        );
    },
    renderMemberListDecorator({ user }) {
        if (!settings.store.showInMemberList) return null;
        return user == null ? null : <VoiceChannelIndicator userId={user.id} />;

    },
    renderMessageDecoration({ message }) {
        if (!settings.store.showInMessages) return null;
        return message?.author == null ? null : <VoiceChannelIndicator userId={message.author.id} isMessageIndicator />;
    },
    patches: [
        // Friends List
        {
            find: "null!=this.peopleListItemRef.current",
            replacement: {
                match: /\.isProvisional.{0,50}?className:\i\.\i,children:\[(?<=isFocused:(\i).+?)/,
                replace: "$&$self.VoiceChannelIndicator({userId:this?.props?.user?.id,isActionButton:true,shouldHighlight:$1}),"
            },
            predicate: () => settings.store.showInMemberList
        }
    ],

    VoiceChannelIndicator
});
