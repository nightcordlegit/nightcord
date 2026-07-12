/*
 * Vencord, a Discord client mod
 * Copyright (c) 2026 Vendicated and contributors
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

import { Divider } from "@components/Divider";
import { FormSwitch } from "@components/FormSwitch";
import { HeadingPrimary, HeadingSecondary } from "@components/Heading";
import { Margins } from "@utils/margins";
import { ModalCloseButton, ModalContent, ModalHeader, ModalProps, ModalRoot } from "@utils/modal";
import { React, Select,useMemo } from "@webpack/common";

import { settings } from "./settings";
import { cl, getLanguages } from "./utils";

const LanguageSettingKeys = ["receivedInput", "receivedOutput", "sentInput", "sentOutput"] as const;

function LanguageSelect({ settingsKey, includeAuto }: { settingsKey: typeof LanguageSettingKeys[number]; includeAuto: boolean; }) {
    const currentValue = settings.use([settingsKey])[settingsKey];

    const options = useMemo(
        () => {
            const options = Object.entries(getLanguages()).map(([value, label]) => ({ value, label }));
            if (!includeAuto)
                options.shift();

            return options;
        }, [includeAuto]
    );

    return (
        <section className={Margins.bottom16}>
            <HeadingSecondary style={{ marginBottom: "8px" }}>
                {settings.def[settingsKey].description}
            </HeadingSecondary>

            <Select
                options={options}
                isSelected={(v: string) => v === currentValue}
                select={(v: string) => settings.store[settingsKey] = v}
                serialize={(v: string) => v}
                renderOptionLabel={(o: any) => <div>{o.label}</div>}
                renderOptionValue={(selected: any[]) => {
                    const option = selected[0];
                    return option ? option.label : (getLanguages() as any)[currentValue] || currentValue;
                }}
                popoutPosition="top"
            />
        </section>
    );
}

function AutoTranslateToggle() {
    const value = settings.use(["autoTranslate"]).autoTranslate;

    return (
        <FormSwitch
            title="Auto Translate"
            description={settings.def.autoTranslate.description}
            value={value}
            onChange={v => settings.store.autoTranslate = v}
            hideBorder
        />
    );
}

export function TranslateModal({ rootProps }: { rootProps: ModalProps; }) {
    return (
        <ModalRoot {...rootProps}>
            <ModalHeader className={cl("modal-header")}>
                <HeadingPrimary className={cl("modal-title")}>
                    Translate
                </HeadingPrimary>
                <ModalCloseButton onClick={rootProps.onClose} />
            </ModalHeader>

            <ModalContent className={cl("modal-content")}>
                {LanguageSettingKeys.map(s => (
                    <LanguageSelect
                        key={s}
                        settingsKey={s}
                        includeAuto={s.endsWith("Input")}
                    />
                ))}

                <Divider className={Margins.bottom16} />

                <AutoTranslateToggle />
            </ModalContent>
        </ModalRoot>
    );
}
