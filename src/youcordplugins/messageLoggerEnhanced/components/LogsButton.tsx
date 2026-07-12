/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import { HeaderBarButton } from "@api/HeaderBar";
import { LogIcon as LogsIcon } from "@components/Icons";
import { cl } from "@youcordplugins/messageLoggerEnhanced/index";

import { openLogModal } from "./LogsModal";

export function OpenLogsButton() {
    return (
        <HeaderBarButton
            className={cl("toolbox-btn")}
            onClick={() => openLogModal()}
            tooltip={"Open Logs"}
            icon={LogsIcon}
        />
    );
}
