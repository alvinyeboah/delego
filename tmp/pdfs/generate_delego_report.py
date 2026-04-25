from pathlib import Path
from datetime import datetime

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    SimpleDocTemplate,
    Paragraph,
    Spacer,
    PageBreak,
    Table,
    TableStyle,
    Image,
)


ROOT = Path("/Users/alvinyeboah/Documents/projects/code/delego")
OUT_DIR = ROOT / "output" / "pdf"
OUT_FILE = OUT_DIR / "delego_project_report.pdf"
STUDENT_NAME = "Alvin Koranteng Yeboah"
STUDENT_ID = "98452026"
COURSE = "[25-26_SEM2_CS443_A] - Mobile Application Development / Mobile Web Programming"
ERD_IMAGE = ROOT / "tmp" / "pdfs" / "assets" / "delego_erd.png"


def make_styles():
    styles = getSampleStyleSheet()
    styles.add(
        ParagraphStyle(
            "TitleCustom",
            parent=styles["Title"],
            fontSize=24,
            leading=28,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#0B0F14"),
            spaceAfter=14,
        )
    )
    styles.add(
        ParagraphStyle(
            "Subtitle",
            parent=styles["Normal"],
            fontSize=11,
            leading=16,
            alignment=TA_CENTER,
            textColor=colors.HexColor("#394150"),
            spaceAfter=10,
        )
    )
    styles.add(
        ParagraphStyle(
            "H1",
            parent=styles["Heading1"],
            fontSize=16,
            leading=20,
            textColor=colors.HexColor("#132033"),
            spaceBefore=6,
            spaceAfter=8,
        )
    )
    styles.add(
        ParagraphStyle(
            "H2",
            parent=styles["Heading2"],
            fontSize=12,
            leading=15,
            textColor=colors.HexColor("#1D2D44"),
            spaceBefore=6,
            spaceAfter=6,
        )
    )
    styles.add(
        ParagraphStyle(
            "Body",
            parent=styles["Normal"],
            fontSize=10.5,
            leading=16,
            alignment=TA_JUSTIFY,
            spaceAfter=8,
        )
    )
    styles.add(
        ParagraphStyle(
            "BulletItem",
            parent=styles["Body"],
            leftIndent=14,
            bulletIndent=2,
            spaceAfter=4,
        )
    )
    return styles


def header_footer(canvas, doc):
    canvas.saveState()
    page_no = canvas.getPageNumber()
    canvas.setFont("Helvetica", 9)
    canvas.setFillColor(colors.HexColor("#5B6575"))
    canvas.drawString(2 * cm, 1.2 * cm, "Delego - Field Operations Platform Report")
    canvas.drawRightString(A4[0] - 2 * cm, 1.2 * cm, f"Page {page_no}")
    canvas.restoreState()


def p(text, styles):
    return Paragraph(text, styles["Body"])


def h1(text, styles):
    return Paragraph(text, styles["H1"])


def h2(text, styles):
    return Paragraph(text, styles["H2"])


def bullet(text, styles):
    return Paragraph(f"• {text}", styles["BulletItem"])


def make_stack_table():
    cell = ParagraphStyle(
        "TableCell",
        fontName="Helvetica",
        fontSize=8.8,
        leading=11,
    )
    head = ParagraphStyle(
        "TableHead",
        fontName="Helvetica-Bold",
        fontSize=9.4,
        leading=11,
        textColor=colors.white,
    )
    data = [
        ["Layer", "Technology", "Purpose in Delego"],
        ["Mobile App", "Flutter + Riverpod + Dio + SQLite", "Task board, capture flow, offline queue, alerts, sync UI"],
        ["API", "NestJS + Prisma + PostgreSQL", "Authentication, tenancy, task lifecycle, capture intake, analytics, audit"],
        ["Worker", "NestJS worker + OCR service", "Background processing such as text extraction from capture images"],
        ["Realtime", "Socket.IO gateway", "Push operational changes to connected clients"],
        ["Infrastructure", "Docker Compose + Redis + Postgres", "Run services, queue/cache support, persistence"],
    ]
    wrapped = [[Paragraph(x, head) for x in data[0]]]
    for row in data[1:]:
        wrapped.append([Paragraph(x, cell) for x in row])
    t = Table(wrapped, colWidths=[3.2 * cm, 5.3 * cm, 7.5 * cm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#132033")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("GRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#C5CBD5")),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F7F9FC")]),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
            ]
        )
    )
    return t


def make_requirements_table():
    cell = ParagraphStyle(
        "ReqCell",
        fontName="Helvetica",
        fontSize=8.4,
        leading=10.6,
    )
    head = ParagraphStyle(
        "ReqHead",
        fontName="Helvetica-Bold",
        fontSize=9.2,
        leading=10.8,
        textColor=colors.white,
    )
    data = [
        ["ID", "Requirement", "Acceptance criteria"],
        ["FR-01", "User authentication", "User can register/login and enter the app shell."],
        ["FR-02", "Task lifecycle", "User can create task and update status on the board."],
        ["FR-03", "Capture workflow", "User can upload image and save capture evidence."],
        ["FR-04", "Synchronization", "User can pull updates and flush queued operations."],
        ["FR-05", "Alerts", "User can view alerts and create alert entries."],
        ["FR-06", "Admin visibility", "User can access tenant, audit, and analytics views."],
        ["NFR-01", "Availability", "Core flows remain usable under typical network variability."],
        ["NFR-02", "Security", "Authenticated access and scoped data boundaries are enforced."],
        ["NFR-03", "Usability", "Main flows are discoverable with minimal navigation depth."],
    ]
    wrapped = [[Paragraph(x, head) for x in data[0]]]
    for row in data[1:]:
        wrapped.append([Paragraph(x, cell) for x in row])
    t = Table(wrapped, colWidths=[2.2 * cm, 5.6 * cm, 8.2 * cm])
    t.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#132033")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("GRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#C7CED8")),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F8FAFD")]),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    return t


def build_story(styles):
    s = []
    today = datetime.now().strftime("%d %b %Y")
    s.append(Spacer(1, 2.3 * cm))
    s.append(Paragraph("DELEGO PROJECT REPORT", styles["TitleCustom"]))
    s.append(Paragraph("Case scenario, architecture, implementation, and demo narrative", styles["Subtitle"]))
    s.append(Paragraph(STUDENT_NAME, styles["Subtitle"]))
    s.append(Paragraph(f"Student ID: {STUDENT_ID}", styles["Subtitle"]))
    s.append(Paragraph(COURSE, styles["Subtitle"]))
    s.append(Paragraph(f"Prepared on: {today}", styles["Subtitle"]))
    s.append(Spacer(1, 0.8 * cm))
    s.append(
        p(
            "This report documents the Delego mobile-first operations platform. "
            "It follows the assignment structure for planning, architecture, implementation "
            "details, and a practical video-demo script.",
            styles,
        )
    )
    s.append(Spacer(1, 1.0 * cm))
    s.append(h2("Student details", styles))
    s.append(p(f"Name: {STUDENT_NAME}", styles))
    s.append(p(f"Student number: {STUDENT_ID}", styles))
    s.append(p(f"Course: {COURSE}", styles))
    s.append(PageBreak())

    s.append(h1("1. Activity 1 - Planning, Case Scenario, and Contract", styles))
    s.append(h2("1.1 Case scenario", styles))
    s.append(
        p(
            "Delego addresses a common operational challenge in distributed teams: work instructions, "
            "field evidence, and reporting are often split across chats, spreadsheets, and ad hoc tools. "
            "The proposed case organization is a regional logistics and site-services provider managing "
            "inspection visits, delivery confirmations, and corrective maintenance requests across "
            "multiple locations.",
            styles,
        )
    )
    s.append(
        p(
            "The organization needs a secure and traceable system where supervisors create tasks, assign "
            "work to field staff, receive image evidence from site visits, and monitor completion status "
            "in near real time. Field staff require a mobile app that remains usable with unstable network "
            "conditions and synchronizes updates when connectivity is restored.",
            styles,
        )
    )
    s.append(h2("1.2 Client background and target market", styles))
    s.append(bullet("Client type: Medium-sized operations company with field teams and centralized supervision.", styles))
    s.append(bullet("Primary users: Dispatchers, team leads, field agents, and compliance reviewers.", styles))
    s.append(bullet("Target market: Logistics, facilities management, utility maintenance, and inspection workflows.", styles))
    s.append(bullet("Business value: Faster cycle times, fewer lost updates, and stronger audit evidence.", styles))
    s.append(Spacer(1, 0.2 * cm))
    s.append(h2("1.3 Functional contract (what the app must do)", styles))
    s.append(bullet("User registration and login with tenant-based access scope.", styles))
    s.append(bullet("Task creation, assignment, status updates, and board-style tracking.", styles))
    s.append(bullet("Capture workflow: choose photo, upload, save capture record, optional text recognition.", styles))
    s.append(bullet("Offline queue for selected actions and controlled synchronization.", styles))
    s.append(bullet("Alerts and notifications UI for user-facing operational updates.", styles))
    s.append(bullet("Command center with profile, organization map, audit history, and analytics event controls.", styles))
    s.append(Spacer(1, 0.2 * cm))
    s.append(h2("1.4 Requirement matrix", styles))
    s.append(
        p(
            "Table 1 maps key requirements to measurable acceptance checks used for prototype validation.",
            styles,
        )
    )
    s.append(make_requirements_table())
    s.append(PageBreak())

    s.append(h1("2. Non-functional Requirements", styles))
    s.append(
        p(
            "The following non-functional requirements guided design and implementation choices for Delego:",
            styles,
        )
    )
    s.append(h2("2.1 Performance and responsiveness", styles))
    s.append(
        bullet(
            "Typical interactions (task list refresh, create/update actions) should complete within acceptable mobile UX thresholds under normal network conditions.",
            styles,
        )
    )
    s.append(
        bullet(
            "UI must remain responsive during background synchronization and image upload flows.",
            styles,
        )
    )
    s.append(h2("2.2 Reliability and offline tolerance", styles))
    s.append(
        bullet(
            "Queued operations must persist locally and remain available for retry after app restart.",
            styles,
        )
    )
    s.append(
        bullet(
            "Conflict reporting ensures that data disagreements are captured rather than silently overwritten.",
            styles,
        )
    )
    s.append(h2("2.3 Security and access control", styles))
    s.append(
        bullet(
            "Authenticated endpoints and tenant scoping protect operational data from unauthorized access.",
            styles,
        )
    )
    s.append(
        bullet(
            "Client sessions use bearer-token authentication and secure storage for device-related credentials.",
            styles,
        )
    )
    s.append(h2("2.4 Maintainability and scalability", styles))
    s.append(
        bullet(
            "Codebase is organized into modules by domain (identity, tasks, capture, sync, analytics, audit, notifications).",
            styles,
        )
    )
    s.append(
        bullet(
            "Worker service decouples heavy processing (OCR pipeline) from the mobile client and API request path.",
            styles,
        )
    )
    s.append(Spacer(1, 0.3 * cm))
    s.append(
        p(
            "These requirements directly support production-readiness and long-term extension of Delego into larger deployments.",
            styles,
        )
    )
    s.append(PageBreak())

    s.append(h1("3. Activity 2 - Prototyping, Specification, Architecture & Design", styles))
    s.append(h2("3.1 High-level architecture", styles))
    s.append(
        p(
            "Delego is a multi-service architecture with a Flutter client, an API service, and a worker service. "
            "The API handles transactional business workflows, while the worker handles asynchronous pipeline tasks "
            "such as OCR processing. PostgreSQL is the primary system of record and Redis supports queue and helper "
            "runtime concerns.",
            styles,
        )
    )
    s.append(Spacer(1, 0.2 * cm))
    s.append(make_stack_table())
    s.append(Spacer(1, 0.35 * cm))
    s.append(h2("3.2 User interaction design", styles))
    s.append(
        bullet(
            "Login screen emphasizes fast entry and clear role transition into daily operations.",
            styles,
        )
    )
    s.append(
        bullet(
            "Bottom navigation exposes five core modules: Board, Capture, Sync, Alerts, Command.",
            styles,
        )
    )
    s.append(
        bullet(
            "Design language uses dark, high-contrast surfaces and consistent card-based sectioning for field readability.",
            styles,
        )
    )
    s.append(h2("3.3 Interaction between interfaces (prototype behavior)", styles))
    s.append(
        p(
            "The prototype demonstrates interaction between interface layers as follows: Login interface authenticates "
            "the user and opens App Shell; App Shell routes users to Board/Capture/Sync/Alerts/Command interfaces; "
            "Capture interface invokes upload and pipeline actions and returns to task context; Sync interface pulls "
            "server state and updates Board UI; Command interface displays tenant/audit/analytics administrative views. "
            "This interaction path was validated during app run sessions.",
            styles,
        )
    )
    s.append(h2("3.4 Prototype web link", styles))
    s.append(
        p(
            "Prototype web access used in implementation and demonstration: local Chrome run via "
            "\"flutter run -d chrome\".",
            styles,
        )
    )
    s.append(
        p(
            "Example local run used for demonstration: flutter run -d chrome",
            styles,
        )
    )
    s.append(h2("3.5 Entity relationship diagram requirement", styles))
    s.append(
        p(
            "Figure ER-1 below provides the conceptual ERD aligned with current schema entities "
            "(User, Tenant, Organization, Workspace, Task, CaptureSession, CaptureImage, Notification, AuditLog).",
            styles,
        )
    )
    if ERD_IMAGE.exists():
        s.append(Image(str(ERD_IMAGE), width=16.2 * cm, height=9.6 * cm))
    s.append(Spacer(1, 0.15 * cm))
    s.append(Paragraph("Figure ER-1: Delego conceptual entity relationship diagram.", styles["Body"]))
    s.append(PageBreak())

    s.append(h1("4. Core Data and Process Flows", styles))
    s.append(h2("4.1 Capture and OCR pipeline flow", styles))
    s.append(
        p(
            "1) User selects image in mobile app. 2) Image uploads and returns a storage reference. "
            "3) App creates capture session linked to workspace and user context. 4) Optional recognition "
            "request triggers server-side processing. 5) Worker processes image and returns extracted text metadata.",
            styles,
        )
    )
    s.append(h2("4.2 Sync and conflict flow", styles))
    s.append(
        p(
            "Sync page pulls current task state with a checkpoint marker. Local queue allows deferred writes. "
            "If version mismatches occur, the app can report a conflict entry with local and server versions. "
            "This preserves visibility into race conditions and supports supervised resolution.",
            styles,
        )
    )
    s.append(h2("4.3 Command and compliance flow", styles))
    s.append(
        p(
            "Command center aggregates account, tenant/workspace hierarchy, audit logs, analytics emission, and "
            "live update channel state. This creates a lightweight operations console directly on mobile.",
            styles,
        )
    )
    s.append(h2("4.4 Key entities (conceptual model)", styles))
    cell = ParagraphStyle(
        "EntityCell",
        fontName="Helvetica",
        fontSize=8.5,
        leading=10.8,
    )
    head = ParagraphStyle(
        "EntityHead",
        fontName="Helvetica-Bold",
        fontSize=9.2,
        leading=10.8,
        textColor=colors.white,
    )
    ent = [
        ["Entity", "Description", "Primary relationships"],
        ["User", "Authenticated person in a tenant scope", "Belongs to Tenant; can own tasks and captures"],
        ["Tenant / Organization / Workspace", "Multi-level operational grouping", "Contains tasks, captures, checkpoints"],
        ["Task", "Unit of work with status and priority", "Assigned to user(s); appears in board and sync"],
        ["CaptureSession", "Field evidence package", "Contains image reference and capture metadata"],
        ["Notification", "User-facing alert", "Linked to a user and read state"],
        ["AuditLog", "Compliance trail entry", "Linked to tenant and actor context"],
    ]
    ent_wrapped = [[Paragraph(x, head) for x in ent[0]]]
    for row in ent[1:]:
        ent_wrapped.append([Paragraph(x, cell) for x in row])
    et = Table(ent_wrapped, colWidths=[3.3 * cm, 6.2 * cm, 6.5 * cm])
    et.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1D2D44")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("GRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#CFD5DE")),
                ("ROWBACKGROUNDS", (0, 1), (-1, -1), [colors.white, colors.HexColor("#F6F8FB")]),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    s.append(et)
    s.append(PageBreak())

    s.append(h1("5. Activity 3 - Implementation Details", styles))
    s.append(h2("5.1 Tools, libraries, and frameworks", styles))
    s.append(bullet("Language stack: Dart (Flutter), TypeScript (NestJS), SQL (PostgreSQL).", styles))
    s.append(bullet("Mobile: Riverpod state management, Dio networking, SQLite local persistence.", styles))
    s.append(bullet("Backend: NestJS modular architecture, Prisma ORM, JWT authentication.", styles))
    s.append(bullet("Async worker: NestJS worker with OCR service and queue-friendly processing model.", styles))
    s.append(bullet("DevOps: Docker Compose for local orchestration of API, worker, Redis, and Postgres.", styles))
    s.append(h2("5.2 Notable engineering choices", styles))
    s.append(
        p(
            "The project separates user-facing operations from background processing. This keeps the app responsive "
            "while enabling scalable processing on the worker side. Another important decision is tenant-first modeling, "
            "ensuring all major operations carry tenant/workspace context for safe multitenancy.",
            styles,
        )
    )
    s.append(
        p(
            "Recent implementation updates include real media upload flow for captures, server-side registration "
            "of device tokens, and pipeline invocation from the app through the API. The UI was also refined to remove "
            "developer-facing route labels so end users only see business language.",
            styles,
        )
    )
    s.append(h2("5.3 Build and runtime outputs", styles))
    s.append(
        bullet(
            "Flutter analysis checks passed for current mobile source set.",
            styles,
        )
    )
    s.append(
        bullet(
            "API build and e2e checks passed in local environment.",
            styles,
        )
    )
    s.append(PageBreak())

    s.append(h1("6. Application Screens and Prototype Notes", styles))
    s.append(h2("6.1 Login and identity", styles))
    s.append(
        p(
            "The login experience uses a brand-first dark theme with concise copy and clear account creation flow. "
            "The branded icon, app name (Delego), and splash visuals provide a consistent first impression on launch.",
            styles,
        )
    )
    s.append(h2("6.2 Operations board", styles))
    s.append(
        p(
            "The board screen surfaces active tasks and supports status progression. It is intended to be the default "
            "control panel for day-to-day dispatch and field monitoring.",
            styles,
        )
    )
    s.append(h2("6.3 Capture", styles))
    s.append(
        p(
            "Capture supports selecting and uploading images, creating evidence sessions, and running optional text "
            "recognition. The wording in this module is now customer-friendly and avoids exposing backend implementation details.",
            styles,
        )
    )
    s.append(h2("6.4 Sync and alerts", styles))
    s.append(
        p(
            "Sync provides user control over pull operations and queue flushing. Alerts give lightweight communication "
            "signals relevant to the currently authenticated operator.",
            styles,
        )
    )
    s.append(h2("6.5 Command center", styles))
    s.append(
        p(
            "The command area acts as an advanced view for administrators or power users. It combines profile data, "
            "tenant/workspace structure, audit timeline, analytics event dispatch, and live connection state.",
            styles,
        )
    )
    s.append(h2("6.6 Prototype evidence checklist", styles))
    s.append(bullet("Figure 1: Login + branded splash screen.", styles))
    s.append(bullet("Figure 2: Board screen with one task status change.", styles))
    s.append(bullet("Figure 3: Capture workflow with image and saved entry.", styles))
    s.append(bullet("Figure 4: Sync view with queue/checkpoint action.", styles))
    s.append(bullet("Figure 5: Command view showing audit/analytics area.", styles))
    s.append(
        p(
            "If a physical mobile device is unavailable, screenshot evidence may be captured from the Chrome/web "
            "or desktop build, provided the same functional flows are clearly visible.",
            styles,
        )
    )
    s.append(PageBreak())

    s.append(h1("7. Activity 4 - Video Demonstration Evidence", styles))
    s.append(
        p(
            "Submission requirement: include one public video link showing implemented app features and "
            "selected code walkthrough points.",
            styles,
        )
    )
    s.append(h2("7.1 Required metadata", styles))
    s.append(bullet("Video link: submitted with final LMS package (Loom/Drive URL).", styles))
    s.append(bullet("Duration: target 10-15 minutes (within rubric maximum).", styles))
    s.append(bullet("Presenter: Alvin Koranteng Yeboah", styles))
    s.append(bullet("Demo platform: Android device or Chrome/web fallback", styles))
    s.append(h2("7.2 Minimum demonstration coverage", styles))
    s.append(bullet("Authentication and app shell navigation.", styles))
    s.append(bullet("Task board interaction (create/update/status).", styles))
    s.append(bullet("Capture flow including upload and saved session.", styles))
    s.append(bullet("Sync flow and queue behavior.", styles))
    s.append(bullet("Command center overview with audit/analytics.", styles))
    s.append(PageBreak())

    s.append(h1("8. Testing, Risks, and Future Work", styles))
    s.append(h2("8.1 Current validation scope", styles))
    s.append(
        bullet("Static analysis and integration checks were executed for active modules.", styles)
    )
    s.append(
        bullet("Manual device run validated primary navigation and key data-entry flows.", styles)
    )
    s.append(h2("8.2 Known risks", styles))
    s.append(
        bullet(
            "Mobile UX can degrade if long-running operations are not isolated from UI thread behavior.",
            styles,
        )
    )
    s.append(
        bullet(
            "Data conflicts increase with multi-operator parallel edits if workflow governance is weak.",
            styles,
        )
    )
    s.append(
        bullet(
            "Push-notification quality depends on production token lifecycle and provider configuration.",
            styles,
        )
    )
    s.append(h2("8.3 Recommended next steps", styles))
    s.append(
        bullet("Introduce role-based permissions by operational persona (dispatcher, reviewer, field agent).", styles)
    )
    s.append(
        bullet("Expand analytics dashboards and KPI views for manager-level reporting.", styles)
    )
    s.append(
        bullet("Add richer capture metadata and optional AI-assisted classification pipeline.", styles)
    )
    s.append(
        bullet("Prepare production release hardening: CI/CD gates, observability, and incident playbooks.", styles)
    )
    s.append(PageBreak())

    s.append(h1("9. Conclusion", styles))
    s.append(
        p(
            "Delego demonstrates an end-to-end operations platform that balances immediate usability for field teams "
            "with a scalable architecture for backend processing and compliance. The project combines task management, "
            "field capture, synchronization, and administrative visibility in one cohesive mobile experience.",
            styles,
        )
    )
    s.append(
        p(
            "From an academic perspective, the solution satisfies case-driven requirements across planning, architecture, "
            "implementation, and demonstration readiness. From a product perspective, it creates a practical foundation "
            "that can be expanded into enterprise workflows with stronger automation and analytics maturity.",
            styles,
        )
    )
    s.append(Spacer(1, 0.35 * cm))
    s.append(h2("Appendix - quick submission checklist", styles))
    s.append(bullet("APK or installable build attached (if required by your course).", styles))
    s.append(bullet("Video demo link included and publicly accessible.", styles))
    s.append(bullet("Source code link included (GitHub or class repository).", styles))
    s.append(bullet("This report exported as PDF and attached to submission package.", styles))
    return s


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    styles = make_styles()
    doc = SimpleDocTemplate(
        str(OUT_FILE),
        pagesize=A4,
        leftMargin=2.0 * cm,
        rightMargin=2.0 * cm,
        topMargin=1.7 * cm,
        bottomMargin=1.8 * cm,
        title="Delego Project Report",
        author="Delego Project Team",
    )
    story = build_story(styles)
    doc.build(story, onFirstPage=header_footer, onLaterPages=header_footer)
    print(str(OUT_FILE))


if __name__ == "__main__":
    main()
